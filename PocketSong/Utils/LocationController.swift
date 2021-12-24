//
//  LocationController.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 12/24/21.
//

import Foundation
import CoreLocation

class LocationController  {
    static let shared = LocationController()
    
    // locationManager variables
    var locManager = CLLocationManager()
    
    private init() { }
    
    func setupLocationManager(delegate:CLLocationManagerDelegate){
        locManager.delegate = delegate
        locManager.desiredAccuracy = kCLLocationAccuracyBest
    }
}
