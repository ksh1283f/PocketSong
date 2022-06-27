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
