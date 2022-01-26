//
//  LocationModel.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 12/25/21.
//

import Foundation

class LocationModel {
    let country:String?
    let locality:String?
    let administrativeArea:String?
    let createdTimeString:String?
    let street:String?
    private let createdTimeData: Date?
    
    let latitude:Double?
    let longitude:Double?
    
    let addressInfo:String?
    
    init(country:String, administrativeArea:String, locality:String, street:String, timeData:Date, latitude:Double, longitude:Double){
        self.country = country
        self.administrativeArea = administrativeArea
        self.locality = locality
        self.street = street
        self.createdTimeData = timeData
        
        self.latitude = latitude
        self.longitude = longitude
        
        if let timeData = self.createdTimeData{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd a hh:mm"
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
            self.createdTimeString = dateFormatter.string(from: timeData)
        }else {
            self.createdTimeString = ""
        }
        
        self.addressInfo = "\(self.country!) \(self.administrativeArea!) \(self.locality!) \(self.street!)  \(self.createdTimeString!)"
        print("locationData initialized!")
    
    }
}
