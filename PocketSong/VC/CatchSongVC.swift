//
//  CatchSongVC.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 11/15/21.
//

import UIKit
import ShazamKit

class CatchSongVC: UIViewController {
    
    @IBOutlet weak var InfomationLabel: UILabel!
    @IBOutlet weak var robotImage: UIImageView!
    @IBOutlet weak var btnCatch: UIButton!
    
    var shazamController:ShazamController?
    var shazamData:ShazamModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if shazamController == nil{
            shazamController = ShazamController(matchHandler: onShazamed)
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startImageInitAnimation()
    }
    
    func startImageInitAnimation() {
        //todo effect
        // 1. label typing effect
        InfomationLabel.playTypingEffect(textValue: "Let's start catch your memory!")
        
        // 2. robot image animation(jumping or moving left and right)
        
        // => looping
    }
    
    func startImageShazamAnimation(){
        // todo effect
        // 1. play a symbol likes wifi
    }
    
    @IBAction func onClickedBtnCatch(_ sender: Any) {
        startImageShazamAnimation()
        
        
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
            // matched?.title
            // matched?.subtitle
            // matched?.artist
            // matched?.artworkURL
            if let mediaItem = matched{
//                shazamData = ShazamModel(coverUrl: <#T##URL?#>, artist: <#T##String?#>, artworkURL: <#T##URL?#>, title: <#T##String?#>, appleMusicURL: <#T##URL?#>, letitude: <#T##Float?#>, longitude: <#T##Float?#>)
            }
            
            performSegue(withIdentifier: "CatchedSongDetail", sender: self)
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let catchedSongVC = segue.destination as? CatchedSongDetailVC{
            // todo initilize catchedSongData
            if let songData = shazamData{
                
            }
        }
        
        
    }
}

