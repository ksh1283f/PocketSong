//
//  MyMemoriesVCViewController.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 11/14/21.
//

import UIKit
import MapKit

class MyMemoriesVC: UIViewController{
    var locManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        // Do any additional setup after loading the view.
        locManager.requestWhenInUseAuthorization()
        locManager.requestAlwaysAuthorization()
        
        switch locManager.authorizationStatus {
        case .authorizedWhenInUse:
            setupMapViewWithCurrentPosition()
            break
        case .authorizedAlways:
            setupMapViewWithCurrentPosition()
            break
        default:
            break
        }
    }
    
    func setupMapViewWithCurrentPosition(){
        guard let initLocation = locManager.location else {
            return
        }
        let cLatitude = initLocation.coordinate.latitude
        let cLongitude = initLocation.coordinate.longitude
        
        print("\(cLatitude) and \(cLongitude)")
        mapView.centerToLocation(CLLocation(latitude: initLocation.coordinate.latitude, longitude: initLocation.coordinate.longitude))
    }
    
    
    func updateMyMemoriInfo(){
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
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
    }
}
