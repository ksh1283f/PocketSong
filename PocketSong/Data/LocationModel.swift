//
//  LocationModel.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 12/25/21.
//

import Foundation

class LocationModel {
    let streetNumber:String?
    let streetName:String?
    let country:String?
    let locality:String?
    let createdTimeString:String?
    
    private let createdTimeData: Date?
    
    init(streetNumber:String, streetName:String, country:String, locality:String, createdTimeData:Date){
        self.streetNumber = streetNumber
        self.streetName = streetName
        self.country = country
        self.locality = locality
        self.createdTimeData = createdTimeData
        
        if let timeData = self.createdTimeData{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd a hh:mm"
            createdTimeString = dateFormatter.string(from: timeData)
        }else{
            createdTimeString = ""
        }
    }
}
