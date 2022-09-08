//
//  RecordData.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 1/26/22.
//

import Foundation

struct RecordData{
    let locationData:LocationModel?
    let shazamData:ShazamModel?
    let comment:String?
    
    
    init(locationData:LocationModel, shazamData:ShazamModel, comment:String = ""){
        self.locationData = locationData
        self.shazamData = shazamData
        self.comment = comment
    }
    
    init(){
        locationData = nil
        shazamData = nil
        comment = ""
    }
}
