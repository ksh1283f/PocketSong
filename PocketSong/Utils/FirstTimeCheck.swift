//
//  FirstTimeCheck.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 8/24/22.
//

import Foundation

class FirstTimeCheck {
    static func isFirstTime()->Bool{
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "isFisrtTime") == nil {
//            defaults.set("true", forKey: "isFirstTime")
            return true
        }else {
            return false
        }
    }
}
