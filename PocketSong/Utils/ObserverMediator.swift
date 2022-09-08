//
//  ObserverMediator.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 8/26/22.
//

import Foundation

class ObserverMediator {
    static let shared = ObserverMediator()
    var subject: Subject?

    func setupObserverMediator(subject:Subject){
        self.subject = subject
    }
    
    func addObserverMediate(_ observer:Observer){
        if self.subject == nil {return}
        self.subject?.subscribe(observer: observer)
    }
    
    func removeObserverMediate(_ observer:Observer){
        if self.subject == nil {return }
        self.subject?.unSubscribe(observer: observer)
    }
}
