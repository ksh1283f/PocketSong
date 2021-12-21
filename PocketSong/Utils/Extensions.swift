//
//  Extensions.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 12/22/21.
//

import Foundation
import UIKit


extension UILabel{
    func playTypingEffect(textValue:String, playingDelay: TimeInterval = 3.0){
        // Initialized target uiLabel text to be empty
        self.text = ""
        
        let effectTask = DispatchWorkItem { [weak self] in
            textValue.forEach{ char in
                DispatchQueue.main.async {  // UI update process must be executed in main thread.
                    self?.text?.append(char)
                }
                Thread.sleep(forTimeInterval: playingDelay*0.01)
            }
        }
        
        let dispatchQueue:DispatchQueue = .init(label: "typespeed", qos: .userInteractive)
        dispatchQueue.asyncAfter(deadline: .now()+0.05, execute: effectTask)
    }
    
    /// if loopCount is -1, it means infinity
    func playTypingEffectLoop(textValue:String, playingDelay: TimeInterval = 3.0, loopCount:Int = -1){
        self.text = ""
        
        // todo need how to control this task: cancelling
        let effectTask = DispatchWorkItem { [weak self] in
            
        }
    }
}

extension UIImage{
    
}
