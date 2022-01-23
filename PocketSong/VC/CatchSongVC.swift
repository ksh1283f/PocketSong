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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if shazamController == nil{
            shazamController = ShazamController(matchHandler: onShazamed)
        }
        
        btnCatch.titleLabel?.font = UIFont(name: "Feather-Bold", size: 24)
        informationLabel.font = UIFont(name: "Feather-Bold", size: 24)
        
        informationLabel.charInterval = charInterval
    }
    
    override func viewWillAppear(_ animated: Bool) {
        btnCatch.isUserInteractionEnabled = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // todo implement init process which is typing animation or shazam process
        shazamController?.stopListening()
        shazamData = nil
        locationData = nil
        timer = nil
        setInformationLabelWithoutAnimation(text: initText, resetCharInterval: charInterval)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        }
        informationLabel.text = self.initText
        
        
        // 2. robot image animation(jumping or moving left and right)
        
        // => looping
        
    }
    
    @objc func startRecognizeAnimation(){
        // todo effect
        //// 1. play a symbol likes wifi
    
        informationLabel.onTypingAnimationFinished = {
            self.btnCatch.isUserInteractionEnabled = true
        }
        
        informationLabel.text = recognizeText
    }
    
    @IBAction func onClickedBtnCatch(_ sender: Any) {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.startRecognizeAnimation), userInfo: nil, repeats: true)
        
//        startRecognizeAnimation()
        btnCatch.isUserInteractionEnabled = false;
        
        // start shazam
        do{
            // the app doesn't use custom catalog, so parameter value is nil.
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
                        // todo show alert informing the user
//                        UIAlertController
                        print("place mark is nil");
                        return
                    }
                    
                    let streetNumber:String = placemark.subThoroughfare ?? ""
                    let streetName:String = placemark.subThoroughfare ?? ""
                    let country:String = placemark.country ?? ""
                    let locality:String = placemark.locality ?? ""
                    let city:String = placemark.administrativeArea ?? ""
                    let street:String = placemark.name ?? ""
                    let timeData = Date()
                    
                    let recordAddress:String = "\(country) \(city) \(locality) \(street) \(time)"
                    print("[CatchSongVC] streetNumber: \(streetNumber) streetName: \(streetName) country: \(country) locality: \(locality) city: \(city) time: \(time)")
                    print("[custom] \(recordAddress)")
                    self.locationData = LocationModel(streetNumber: streetNumber, streetName: streetName, country: country, locality: locality, createdTimeData: timeData)
                }
            }
            
            // matched?.title
            // matched?.subtitle
            // matched?.artist
            // matched?.artworkURL
        
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
            if let songData = shazamData{
                catchedSongVC.shazamData = songData
            }else {
                catchedSongVC.locationData = locationData
            }
        }
    }
}
