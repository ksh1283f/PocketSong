//
//  Protocols.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 4/19/22.
//

import Foundation

protocol Subject {
    var observers: [Observer] {get set}
    func subscribe(observer: Observer)
    func unSubscribe(observer: Observer)
    func notify(message:String)
}

protocol Observer {
    var id: String { get set }
    func update(message: String)
}
