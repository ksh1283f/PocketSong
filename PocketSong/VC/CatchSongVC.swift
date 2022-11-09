//
//  CatchSongVC.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 11/15/21.
//

import UIKit
import ShazamKit
import CoreLocation
import CLTypingLabel
import AVFoundation
import Lottie
import SnapKit

class CatchSongVC: UIViewController {
    @IBOutlet weak var btnCatch: UIButton!
    @IBOutlet weak var contentsView: UIView!
    
    let animationView = AnimationView()
    var animationPre:Animation?
    var animationMain:Animation?
    
    var shazamController:ShazamController?
    var shazamData:ShazamModel?
    var locationData:LocationModel?
    
    var id: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if shazamController == nil{
            shazamController = ShazamController(matchHandler: onShazamed)
        }
        
        btnCatch.titleLabel?.font = UIFont(name: "Feather-Bold", size: 24)
        
        id = "CatchSongVC"
        NetworkMonitor.shared.subscribe(observer: self)
        btnCatch.layer.cornerRadius = 15
        btnCatch.layer.shadowColor = UIColor.gray.cgColor
        btnCatch.layer.shadowOffset = CGSize.zero
        btnCatch.layer.shadowRadius = 6
        btnCatch.layer.shadowOpacity = 1.0
        
        self.navigationItem.title = self.title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        btnCatch.isUserInteractionEnabled = true
        btnCatch.alpha = 1.0
        setAni(aniName: "PocketsongCatchSongInAppPre", loopMode: .playOnce)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // todo implement init process which is typing animation or shazam process
        shazamController?.stopListening()
        shazamData = nil
        locationData = nil
        print("[CatchSongVC] viewWillDisappear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.navigationItem.title = self.title
    }

    @IBAction func onClickedBtnCatch(_ sender: Any) {
        
        if setAni(aniName: "PocketsongCatchSongInAppPre", loopMode: .playOnce) {
            animationView.play{ isFinished in
                if !isFinished{
                    print("--- [CatchSongVC] play is not finished ---")
                    return
                }
                
                if self.setAni(aniName: "PocketsongCatchSongInAppMain", loopMode: .loop) {
                    self.animationView.play()
                }
            }
        }
        
        btnCatch.isUserInteractionEnabled = false;
        btnCatch.alpha = 0.0
        
        // start shazam
        do{
            // the app doesn't use custom catalog, so parameter value is nil.
            
            // get location info
            let geoCoder = CLGeocoder()
            if let location = LocationController.shared.locManager.location {
                geoCoder.reverseGeocodeLocation(location){ [weak self] (placemarks, error) in
                    
                    // maybe below code will be useless
                    guard let self = self else { return }
                    
                    if let _error = error{
                        //todo show alert informing the user
                        print("\(_error)")
                        return
                    }
                    
                    guard let placemark = placemarks?.first else{
                        print("place mark is nil");
                        return
                    }
                    
                    let country:String = placemark.country ?? ""
                    let locality:String = placemark.locality ?? ""
                    let city:String = placemark.administrativeArea ?? ""
                    let street:String = placemark.name ?? ""
                    let timeData = Date()
                    
                    self.locationData = LocationModel(country: country, administrativeArea: city, locality: locality, street: street, timeData: timeData, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    print("street data")
                }
            }
            try shazamController?.match(catalog: nil)
        } catch{
            print("shazamController's match handler is not handled.")
        }
    }
    
    func onShazamed(matched:SHMatchedMediaItem?, error:Error?){
        self.animationView.pause()
        
        // isListening = false
        if error != nil {
            print("[CatchSongVC] \(error.debugDescription)")
            let alert = UIAlertController(title: LocalizeText.RecognizingFailedTitle, message: "\(error.debugDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
                self.btnCatch.isUserInteractionEnabled = true;
                self.btnCatch.alpha = 1.0
            })
            self.present(alert, animated: true)
        }else{
            if let mediaItem = matched{
                self.shazamData = ShazamModel(coverUrl: nil, artist: mediaItem.artist, artworkURL: mediaItem.artworkURL, title: mediaItem.title, appleMusicURL: mediaItem.appleMusicURL, addressInfo: nil)
            }else {
                print("[CatchSongVC] \(error.debugDescription)")
                let alert = UIAlertController(title: "Recognizing failed!", message: "\(error.debugDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
                    self.btnCatch.isUserInteractionEnabled = true;
                    self.btnCatch.alpha = 1.0
                })
                self.present(alert, animated: true, completion: nil)
            }
            
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            performSegue(withIdentifier: "ShowCatchedSongDetail", sender: self)
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        print("CatchSongVC -> CatchedSongDetailVC(prepare)")
        if let catchedSongVC = segue.destination as? CatchedSongDetailVC{
            // todo initilize catchedSongData
            if let locationData = locationData {
                catchedSongVC.locationData = locationData
            }else {
                print("[CatchSongVC] locationData is nil")
            }
            if let songData = shazamData {
                catchedSongVC.shazamData = songData
            }else{
                print("[CatchSongVC] shazamData is nil")
            }
        }
    }
}

extension CatchSongVC : Observer {
    func update(message: String) {
        print("[CatchSongVC] \(id) -> \(message)")
        switch message {
        case "disconnected":
            try?shazamController?.stopListening()
            
            DispatchQueue.main.async {
                let alert = UIAlertController(title: LocalizeText.NetworkDisconnectedTitle, message: LocalizeText.NetworkDisconnectedMsg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: LocalizeText.Ok, style: .default){ _ in
                    return
                })
                
                self.present(alert, animated: true, completion: nil)
            }
            
        default:
//            if let _timer = timer{
//                _timer.invalidate()
//            }
//            try?shazamController?.stopListening()
//
//            let alert = UIAlertController(title: "network is disconnected!", message: "Please check your network state and connect cellular or wifi", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
//                return
//            })
//            self.present(alert, animated: true, completion: nil)
            print("connected")
        }
    }
    
    
}

// MARK: - refering to Lottie animation function
extension CatchSongVC {
    private func setAni(aniName:String, loopMode:LottieLoopMode) -> Bool{
        if let ani = getAnimation(aniName: aniName){
            animationView.animation = ani
            animationView.loopMode = loopMode
            if !contentsView.subviews.contains(animationView) {
                animationView.frame = contentsView.bounds
                animationView.backgroundColor = UIColor(hex: 0x009051)
                animationView.backgroundBehavior = .pauseAndRestore
                animationView.isUserInteractionEnabled = true
                contentsView.addSubview(animationView)
                animationView.contentMode = .scaleAspectFit
                
                animationView.snp.makeConstraints{ make in
                    make.center.equalTo(contentsView)
                    make.size.equalTo(contentsView)
                }
            }
            
            return true
        }else {
            print("--- [CatchSong] animation init failed ---")
        }
        
        return false
    }
    
    private func getAnimation(aniName:String) -> Animation?{
        return Animation.named(aniName)
    }
}

//-------------------------
public enum Model : String {

    case simulator     = "simulator",

    iPod1              = "iPod 1",
    iPod2              = "iPod 2",
    iPod3              = "iPod 3",
    iPod4              = "iPod 4",
    iPod5              = "iPod 5",

    iPad2              = "iPad 2",
    iPad3              = "iPad 3",
    iPad4              = "iPad 4",
    iPadAir            = "iPad Air ",
    iPadAir2           = "iPad Air 2",
    iPadAir3           = "iPad Air 3",
    iPad5              = "iPad 5",
    iPad6              = "iPad 6",
    iPad7              = "iPad 7",

    iPadMini           = "iPad Mini",
    iPadMini2          = "iPad Mini 2",
    iPadMini3          = "iPad Mini 3",
    iPadMini4          = "iPad Mini 4",
    iPadMini5          = "iPad Mini 5",

    iPadPro9_7         = "iPad Pro 9.7\"",
    iPadPro10_5        = "iPad Pro 10.5\"",
    iPadPro11          = "iPad Pro 11\"",
    iPadPro12_9        = "iPad Pro 12.9\"",
    iPadPro2_12_9      = "iPad Pro 2 12.9\"",
    iPadPro3_12_9      = "iPad Pro 3 12.9\"",

    iPhone4            = "iPhone 4",
    iPhone4S           = "iPhone 4S",
    iPhone5            = "iPhone 5",
    iPhone5S           = "iPhone 5S",
    iPhone5C           = "iPhone 5C",
    iPhone6            = "iPhone 6",
    iPhone6Plus        = "iPhone 6 Plus",
    iPhone6S           = "iPhone 6S",
    iPhone6SPlus       = "iPhone 6S Plus",
    iPhoneSE           = "iPhone SE",
    iPhone7            = "iPhone 7",
    iPhone7Plus        = "iPhone 7 Plus",
    iPhone8            = "iPhone 8",
    iPhone8Plus        = "iPhone 8 Plus",
    iPhoneX            = "iPhone X",
    iPhoneXS           = "iPhone XS",
    iPhoneXSMax        = "iPhone XS Max",
    iPhoneXR           = "iPhone XR",
    iPhone11           = "iPhone 11",
    iPhone11Pro        = "iPhone 11 Pro",
    iPhone11ProMax     = "iPhone 11 Pro Max",

    AppleTV            = "Apple TV",
    AppleTV_4K         = "Apple TV 4K",
    unrecognized       = "?unrecognized?"
}

public extension UIDevice {

    var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }

        let modelMap : [String: Model] = [
            "i386"      : .simulator,
            "x86_64"    : .simulator,

            "iPod1,1"   : .iPod1,
            "iPod2,1"   : .iPod2,
            "iPod3,1"   : .iPod3,
            "iPod4,1"   : .iPod4,
            "iPod5,1"   : .iPod5,

            "iPad2,1"   : .iPad2,
            "iPad2,2"   : .iPad2,
            "iPad2,3"   : .iPad2,
            "iPad2,4"   : .iPad2,
            "iPad3,1"   : .iPad3,
            "iPad3,2"   : .iPad3,
            "iPad3,3"   : .iPad3,
            "iPad3,4"   : .iPad4,
            "iPad3,5"   : .iPad4,
            "iPad3,6"   : .iPad4,
            "iPad6,11"  : .iPad5,
            "iPad6,12"  : .iPad5,
            "iPad7,5"   : .iPad6,
            "iPad7,6"   : .iPad6,
            "iPad7,11"  : .iPad7,
            "iPad7,12"  : .iPad7,

            "iPad2,5"   : .iPadMini,
            "iPad2,6"   : .iPadMini,
            "iPad2,7"   : .iPadMini,
            "iPad4,4"   : .iPadMini2,
            "iPad4,5"   : .iPadMini2,
            "iPad4,6"   : .iPadMini2,
            "iPad4,7"   : .iPadMini3,
            "iPad4,8"   : .iPadMini3,
            "iPad4,9"   : .iPadMini3,
            "iPad5,1"   : .iPadMini4,
            "iPad5,2"   : .iPadMini4,
            "iPad11,1"  : .iPadMini5,
            "iPad11,2"  : .iPadMini5,

            "iPad6,3"   : .iPadPro9_7,
            "iPad6,4"   : .iPadPro9_7,
            "iPad7,3"   : .iPadPro10_5,
            "iPad7,4"   : .iPadPro10_5,
            "iPad6,7"   : .iPadPro12_9,
            "iPad6,8"   : .iPadPro12_9,
            "iPad7,1"   : .iPadPro2_12_9,
            "iPad7,2"   : .iPadPro2_12_9,
            "iPad8,1"   : .iPadPro11,
            "iPad8,2"   : .iPadPro11,
            "iPad8,3"   : .iPadPro11,
            "iPad8,4"   : .iPadPro11,
            "iPad8,5"   : .iPadPro3_12_9,
            "iPad8,6"   : .iPadPro3_12_9,
            "iPad8,7"   : .iPadPro3_12_9,
            "iPad8,8"   : .iPadPro3_12_9,

            "iPad4,1"   : .iPadAir,
            "iPad4,2"   : .iPadAir,
            "iPad4,3"   : .iPadAir,
            "iPad5,3"   : .iPadAir2,
            "iPad5,4"   : .iPadAir2,
            "iPad11,3"  : .iPadAir3,
            "iPad11,4"  : .iPadAir3,

            "iPhone3,1" : .iPhone4,
            "iPhone3,2" : .iPhone4,
            "iPhone3,3" : .iPhone4,
            "iPhone4,1" : .iPhone4S,
            "iPhone5,1" : .iPhone5,
            "iPhone5,2" : .iPhone5,
            "iPhone5,3" : .iPhone5C,
            "iPhone5,4" : .iPhone5C,
            "iPhone6,1" : .iPhone5S,
            "iPhone6,2" : .iPhone5S,
            "iPhone7,1" : .iPhone6Plus,
            "iPhone7,2" : .iPhone6,
            "iPhone8,1" : .iPhone6S,
            "iPhone8,2" : .iPhone6SPlus,
            "iPhone8,4" : .iPhoneSE,
            "iPhone9,1" : .iPhone7,
            "iPhone9,3" : .iPhone7,
            "iPhone9,2" : .iPhone7Plus,
            "iPhone9,4" : .iPhone7Plus,
            "iPhone10,1" : .iPhone8,
            "iPhone10,4" : .iPhone8,
            "iPhone10,2" : .iPhone8Plus,
            "iPhone10,5" : .iPhone8Plus,
            "iPhone10,3" : .iPhoneX,
            "iPhone10,6" : .iPhoneX,
            "iPhone11,2" : .iPhoneXS,
            "iPhone11,4" : .iPhoneXSMax,
            "iPhone11,6" : .iPhoneXSMax,
            "iPhone11,8" : .iPhoneXR,
            "iPhone12,1" : .iPhone11,
            "iPhone12,3" : .iPhone11Pro,
            "iPhone12,5" : .iPhone11ProMax,

            "AppleTV5,3" : .AppleTV,
            "AppleTV6,2" : .AppleTV_4K
        ]

        if let model = modelMap[String.init(validatingUTF8: modelCode!)!] {
            if model == .simulator {
                if let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                    if let simModel = modelMap[String.init(validatingUTF8: simModelCode)!] {
                        return simModel
                    }
                }
            }
            return model
        }
        return Model.unrecognized
    }
}
