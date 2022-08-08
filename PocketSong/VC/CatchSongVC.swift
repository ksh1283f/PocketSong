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

class CatchSongVC: UIViewController {
    

    @IBOutlet weak var informationLabel: CLTypingLabel!
    @IBOutlet weak var robotImage: UIImageView!
    @IBOutlet weak var btnCatch: UIButton!
    
    let initText = "Let's start catch your memory!"
    let recognizeText = "I'm recognizing...."
    let charInterval = 0.05
    
    var shazamController:ShazamController?
    var shazamData:ShazamModel?
    var locationData:LocationModel?
    var timer:Timer?
    
    var id: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if shazamController == nil{
            shazamController = ShazamController(matchHandler: onShazamed)
        }
        
        btnCatch.titleLabel?.font = UIFont(name: "Feather-Bold", size: 24)
        informationLabel.font = UIFont(name: "Feather-Bold", size: 24)
        
        informationLabel.charInterval = charInterval
        id = "CatchSongVC"
        NetworkMonitor.shared.subscribe(observer: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        btnCatch.isUserInteractionEnabled = false
        btnCatch.alpha = 1.0
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // todo implement init process which is typing animation or shazam process
        shazamController?.stopListening()
        shazamData = nil
        locationData = nil
        print("[CatchSongVC] viewWillDisappear")
        timer?.invalidate()
        setInformationLabelWithoutAnimation(text: initText, resetCharInterval: charInterval)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.navigationItem.title = self.title
        
        startImageInitAnimation()
    
    }
    
    override func didMove(toParent parent: UIViewController?) {
        print("[catchSongVC] didMove")
    }
    
    func startImageInitAnimation() {
        //todo effect
        // 1. label typing effect
//        InfomationLabel.playTypingEffect(textValue: "Let's start catch your memory!",
//                                         onEnd: {() -> () in self.btnCatch.isUserInteractionEnabled = true })
        informationLabel.onTypingAnimationFinished = {
            self.btnCatch.isUserInteractionEnabled = true
            self.btnCatch.alpha = 1.0
        }
        informationLabel.text = self.initText
        
        
        // 2. robot image animation(jumping or moving left and right)
        
        // => looping
        
    }
    
    @objc func startRecognizeAnimation(){
        // todo effect
        //// 1. play a symbol likes wifi
    
        informationLabel.onTypingAnimationFinished = {

        }
        
        informationLabel.text = recognizeText
    }
    
    @IBAction func onClickedBtnCatch(_ sender: Any) {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.startRecognizeAnimation), userInfo: nil, repeats: true)
        
//        startRecognizeAnimation()
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
        if let _timer = timer{
            _timer.invalidate()
        }
        
        // todo end shazam animation
        
        // isListening = false
        if error != nil {
            print("[CatchSongVC] \(error.debugDescription)")
            let alert = UIAlertController(title: "Recognizing failed!", message: "Time out recognizing, check the around music is playing..", preferredStyle: .alert)
            return
        }else{
            if let mediaItem = matched{
                self.shazamData = ShazamModel(coverUrl: nil, artist: mediaItem.artist, artworkURL: mediaItem.artworkURL, title: mediaItem.title, appleMusicURL: mediaItem.appleMusicURL, addressInfo: nil)
            }else {
                print("[CatchSongVC] \(error.debugDescription)")
                let alert = UIAlertController(title: "Recognizing failed!", message: "Time out recognizing, check the around music is playing..", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
                    return
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
            if let _timer = timer{
                _timer.invalidate()
            }
            try?shazamController?.stopListening()
            
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "network is disconnected!", message: "Please check your network state and connect cellular or wifi", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
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
