//
//  Extensions.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 12/22/21.
//

import Foundation
import UIKit


extension UILabel{
    
//    func playTypingEffect(textValue:String, playingDelay: TimeInterval = 3.0, onEnd:@escaping()->Void){
//        // Initialized target uiLabel text to be empty
//        self.text = ""
//        
//        let effectTask = DispatchWorkItem { [weak self] in
//            textValue.forEach{ char in
//                DispatchQueue.main.async {  // UI update process must be executed in main thread.
//                    self?.text?.append(char)
//                }
//                Thread.sleep(forTimeInterval: playingDelay*0.01)
//            }
//            
//            if onEnd != nil{
//                onEnd()
//            }
//        }
//        
//        let dispatchQueue:DispatchQueue = .init(label: "typespeed", qos: .userInteractive)
//        dispatchQueue.asyncAfter(deadline: .now()+0.05, execute: effectTask)
//    }
//    
//    /// if loopCount is -1, it means infinity
//    func playTypingEffectMultiple(textValue:String, playingDelay: TimeInterval = 3.0, onEnd:@escaping()->Void){
//        self.text = ""
//        
//        // todo need how to control this task: cancelling
//        let effectTask = DispatchWorkItem { [weak self] in
//            for _ in 0...15{
//                DispatchQueue.main.async{
//                    self?.text = ""
//                }
//                textValue.forEach{ char in
//                    DispatchQueue.main.async {
//                        self?.text?.append(char)
//                    }
//                    Thread.sleep(forTimeInterval: playingDelay*0.01)
//                }
//                Thread.sleep(forTimeInterval: 2)
//            }
//            if onEnd != nil{
//                onEnd()
//            }
//        }
//        
//        let dispatchQueue:DispatchQueue = .init(label: "typeSpeedLoop", qos:.userInteractive)
//        dispatchQueue.asyncAfter(deadline: .now()+0.05, execute: effectTask)
//    }
}

extension UIImage{
    
}
