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
        // 2. robot image animation(jumping or moving left and right)
        // => looping
    }
    
    func startImageShazamAnimation(){
        // todo effect
        // 1. play a symbol likes wifi
    }
    
    @IBAction func onClickedBtnCatch(_ sender: Any) {
        startImageShazamAnimation()
        // todo start shazam
        
    }
    
    func onShazamed(matched:SHMatchedMediaItem?, error:Error?){
        // isListening = false
        if error != nil {
            print(error.debugDescription)
        }else{
            // matched?.title
            // matched?.subtitle
            // matched?.artist
            // matched?.artworkURL
        }
    }
    
}

