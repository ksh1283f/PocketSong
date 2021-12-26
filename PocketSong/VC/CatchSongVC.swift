//
//  CatchSongVC.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 11/15/21.
//

import UIKit
import ShazamKit
import CoreLocation

class CatchSongVC: UIViewController {
    
    @IBOutlet weak var InfomationLabel: UILabel!
    @IBOutlet weak var robotImage: UIImageView!
    @IBOutlet weak var btnCatch: UIButton!
    
    var shazamController:ShazamController?
    var shazamData:ShazamModel?
    var locationData:LocationModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if shazamController == nil{
            shazamController = ShazamController(matchHandler: onShazamed)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        btnCatch.isUserInteractionEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        startImageInitAnimation()
    }
    
    func startImageInitAnimation() {
        //todo effect
        // 1. label typing effect
        InfomationLabel.playTypingEffect(textValue: "Let's start catch your memory!",
                                         onEnd: {() -> () in self.btnCatch.isUserInteractionEnabled = true })
        
        // 2. robot image animation(jumping or moving left and right)
        
        // => looping
        
    }
    
    func startRecognizeAnimation(){
        // todo effect
        //// 1. play a symbol likes wifi
        InfomationLabel.playTypingEffectMultiple(textValue: "I'm recognizing....", onEnd: {() -> () in self.btnCatch.isUserInteractionEnabled = false})
    }
    
    @IBAction func onClickedBtnCatch(_ sender: Any) {
        startRecognizeAnimation()
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
        
        // todo end shazam animation
        
        // isListening = false
        if error != nil {
            print(error.debugDescription)
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
                        print("place mark is nil");
                        return
                    }
                    
                    let streetNumber:String = placemark.subThoroughfare ?? ""
                    let streetName:String = placemark.subThoroughfare ?? ""
                    let country:String = placemark.country ?? ""
                    let locality:String = placemark.locality ?? ""
                    let time:Date = Date()
                    
                    self.locationData = LocationModel(streetNumber: streetNumber, streetName: streetName, country: country, locality: locality, createdTimeData: time)
                }
            }
            
            // matched?.title
            // matched?.subtitle
            // matched?.artist
            // matched?.artworkURL
        
            if let mediaItem = matched{
                self.shazamData = ShazamModel(coverUrl: nil, artist: matched?.artist, artworkURL: matched?.artworkURL, title: matched?.title, appleMusicURL: matched?.appleMusicURL, letitude: nil, longitude: nil)
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

