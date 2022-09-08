//
//  Types.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 4/19/22.
//

import Foundation

enum E_NetworkStateType:String {
    case none = "none"
    case cellular = "cellular"
    case wifi = "wifi"
    case disconnected = "disconnected"
    
    func getMessage() {
        switch self {
        case .cellular:
            print("network connected on cellular")
            
        case .wifi:
            print("network connected on wifi")
            
        case .disconnected:
            print("network is disconnected state")
            
        default:
            print("not initilized network state")
        }
    }
}

enum EmojiType:String, CaseIterable{
    case rockAndRoll = "🤟"
    case sound = "🔊"
    case control = "🎛"
    case saxophone = "🎷"
    case guitar = "🎸"
    case staff = "🎼"
    case piano = "🎹"
    case drum = "🥁"
    case mic = "🎤"
    case headPhone = "🎧"
    
    static func getRandomEmoji() -> String {
        let randomIndex = Int.random(in: 0..<EmojiType.allCases.count)
        return EmojiType.allCases[randomIndex].rawValue
    }
}
