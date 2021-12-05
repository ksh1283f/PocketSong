//
//  MyMemoriesVCViewController.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 11/14/21.
//

import UIKit
import MapKit
import CoreLocation // to get the user's locations

class MyMemoriesVC: UIViewController{
    
    var locManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkLocationServices()
    }
    
    func setupLocationManager(){
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            // setup our location manager
            setupLocationManager()
            checkLocationAuthorization()
        }else{
            // show alert letting the user know they have to turn this on.
            
        }
    }
    
    func checkLocationAuthorization() {
        switch locManager.authorizationStatus{
        case .authorizedAlways:
            mapView.showsUserLocation = true
            if let presentLocation = locManager.location{
                setupMapViewWithCurrentPosition(presentLocation)
            }else{
                // show alert this situation is invalid
            }
            break

        case .authorizedWhenInUse:
            // do map stuff
            mapView.showsUserLocation = true
            if let presentLocation = locManager.location{
                setupMapViewWithCurrentPosition(presentLocation)
            }else{
                // show alert this situation is invalid
            }
            
            break
            
        case .denied:
            // show alert instructing them how to on permissions
            break
            
        case .notDetermined:
            locManager.requestWhenInUseAuthorization()
            break
            
        case .restricted:
            // show an alert letting them know what's up
            break
        }
    }
    
    func setupMapViewWithCurrentPosition(_ location:CLLocation){
        mapView.centerToLocation(location)
    }
    
    func updateMyMemoriInfo(){
        
    }
    
//    mapView.addAnnotation(<#T##annotation: MKAnnotation##MKAnnotation#>)
}

private extension MKMapView{
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000){
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
        
        // for test function
        //makePin(targetCoordinate: location.coordinate)
    }
    
    func makePin( targetCoordinate: CLLocationCoordinate2D){
        let pin = MKPointAnnotation()
        pin.coordinate = targetCoordinate
        // todo add click event when it is clicked show the description view
        self.addAnnotation(pin)
    }
}

extension MyMemoriesVC : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location  = locations.first{
            locManager.stopUpdatingLocation()
            
            setupMapViewWithCurrentPosition(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if #available(iOS 15, *){
            return
        }
        
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch locManager.authorizationStatus{
        case .authorizedAlways:
            print("authorizedAlways")
            setupLocationManager()
            checkLocationAuthorization()
            break
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            setupLocationManager()
            checkLocationAuthorization()
            break
        case .restricted:
            print("restricted")
            break
        case .notDetermined:
            print("notDetermined")
            break
        case .denied:
            print("denied")
            break
        }
    }
    
    
}
