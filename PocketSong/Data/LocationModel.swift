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
    
    let addressInfo:String?
    
    
    init(streetNumber:String, streetName:String, country:String, locality:String, createdTimeData:Date){
        self.streetNumber = streetNumber
        self.streetName = streetName
        self.country = country
        self.locality = locality
        self.createdTimeData = createdTimeData
        
//        let streetNumber:String = placemark.subThoroughfare ?? ""
//        let streetName:String = placemark.subThoroughfare ?? ""
//        let country:String = placemark.country ?? ""
//        let locality:String = placemark.locality ?? ""
//        let city:String = placemark.administrativeArea ?? ""
//        let street:String = placemark.name ?? ""
//        let timeData = Date()
        
//        let recordAddress:String = "\(country) \(city) \(locality) \(street) \(time)"
        
        if let timeData = self.createdTimeData{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd a hh:mm"
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
            createdTimeString = dateFormatter.string(from: timeData)
        }else{
            createdTimeString = ""
        }
        
        addressInfo = "\(self.country) \(self.c)"
    }
}
