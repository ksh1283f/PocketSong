//
//  MyMemoriesVCViewController.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 11/14/21.
//

import UIKit
import MapKit
import CoreLocation // to get the user's locations
import Network

class MyMemoriesVC: UIViewController, MKMapViewDelegate{
    
//    var locManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        
        // test
        self.mapView.mapType = .standard
        self.mapView.showsBuildings = true
        self.mapView.showsScale = true
        self.mapView.showsCompass = true
        self.mapView.showsTraffic = true
        
        self.mapView.showsLargeContentViewer = true
        
        let testButton = UIButton()
        testButton.frame = CGRect(x: 10, y: 100, width: 200, height: 100)
        testButton.layer.backgroundColor = .init(red: 1, green: 0, blue: 0, alpha: 1)
        testButton.addTarget(self, action: #selector(onClickedTestButton), for: .touchUpInside)
        
        self.view.addSubview(testButton)
    }
    
    /// for test
    @objc private func onClickedTestButton(sender: UIButton!){
        print("[onClickedTestButton] started")
        for anno in mapView.annotations(in: mapView.visibleMapRect){
            print("[onClickedTestButton] \(anno.description)")
            
        }
        
        for anno in mapView.annotations{
            
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkLocationServices()
        mapView.roundCorners(cornerRadius: 20, maskedCorners: [.layerMinXMinYCorner,
                                                               .layerMinXMaxYCorner,
                                                               .layerMaxXMinYCorner,
                                                               .layerMaxXMaxYCorner
                                                              ])
        
        // check data controller has some recordData
        // if it has, get the data and convert it to CLLocationCoordinate2D data
        DataController.dbOpen(caller: String(describing: self)){
            for item in $0 {
                if let locationData = item.locationData, let shazamData = item.shazamData{
                    let location2d = CLLocationCoordinate2D(latitude: locationData.latitude!, longitude: locationData.longitude!)
                    self.mapView.makePin(targetCoordinate: location2d, title: shazamData.title!, subTitle: shazamData.artist!)
                }
            }
        }
    }
    
    func setupLocationManager(){
        LocationController.shared.setupLocationManager(delegate: self)
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            // setup our location manager
            print("[MyMemories:checkLocationServices]")
            setupLocationManager()
            checkLocationAuthorization()
        }else{
            // show alert letting the user know they have to turn this on.
           
        }
    }

    func checkLocationAuthorization() {
        switch LocationController.shared.locManager.authorizationStatus{
        case .authorizedAlways:
            mapView.showsUserLocation = true
            if let presentLocation = LocationController.shared.locManager.location{
                setupMapViewWithCurrentPosition(presentLocation)
            }else{
                // show alert this situation is invalid
                let alert = UIAlertController(title: "Authorization is need!", message: "Please go to Settings -> Pocketsong then activate location and microphone access", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
                    exit(0)
                })
                self.present(alert, animated: true, completion: nil)
            }
            break

        case .authorizedWhenInUse:
            // do map stuff
            mapView.showsUserLocation = true
            if let presentLocation = LocationController.shared.locManager.location{
                setupMapViewWithCurrentPosition(presentLocation)
            }else{
                // show alert this situation is invalid
                let alert = UIAlertController(title: "Authorization is need!", message: "Please go to Settings -> Pocketsong then activate location and microphone access", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
                    exit(0)
                })
                self.present(alert, animated: true, completion: nil)
            }
            
            break
            
        case .denied:
//             show alert instructing them how to on permissions
            let alert = UIAlertController(title: "Authorization is need!", message: "Please go to Settings -> Pocketsong then activate location and microphone access", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
                exit(0)
            })
            self.present(alert, animated: true, completion: nil)
            print("[MyMemories: checkLocationAuthorization] denied")
            break
            
        case .notDetermined:
            LocationController.shared.locManager.requestWhenInUseAuthorization()
            break
            
        case .restricted:
            // show an alert letting them know what's up
            let alert = UIAlertController(title: "Authorization is need!", message: "Please go to Settings -> Pocketsong then activate location and microphone access", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
                exit(0)
            })
            self.present(alert, animated: true, completion: nil)
            break
        }
    }
    
    func setupMapViewWithCurrentPosition(_ location:CLLocation){
        mapView.centerToLocation(location)
    }
    
    func updateMyMemoriInfo(){
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        if let annotationTitle = view.annotation?.title{
            print("User tapped on annotation with title: \(annotationTitle!)")
        }
        
        // todo show detailView about the song
        let descView = UIView()
        descView.frame = self.mapView.bounds
        // image
        // title
        // desc
        // created time
        // coordinate
        
        
        var coverImage = UIImage()  // tood show default image if it doesn't exist
        var title = view.annotation?.title
        var desc = view.annotation?.subtitle
        var createdTime:String?
        var latitude = view.annotation?.coordinate.latitude
        var longitude = view.annotation?.coordinate.longitude
    }
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
    
    func makePin( targetCoordinate: CLLocationCoordinate2D, title:String, subTitle:String){
        let pin = MKPointAnnotation()
        pin.coordinate = targetCoordinate
        pin.title = title
        pin.subtitle = subTitle
        // todo add click event when it is clicked show the description view
        
        self.addAnnotation(pin)
    }
    
   
    
//    func mapView(){
//
//    }
}
extension UIView {
    // make corner rounded shape
    func roundCorners(cornerRadius:CGFloat, maskedCorners:CACornerMask) {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = CACornerMask(arrayLiteral: maskedCorners)
    }
}

extension MyMemoriesVC : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location  = locations.first{
            LocationController.shared.locManager.stopUpdatingLocation()
            
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
        switch LocationController.shared.locManager.authorizationStatus{
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
            let alert = UIAlertController(title: "Request location permission", message:"Please go to 'Settings -> PocketSong -> Allow location access'", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "Allow", style: .default) { (action) in
                if let url = URL(string: "App-prefs:") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
            let cancelAction = UIAlertAction(title: "Don't allow", style: .cancel){ (action) in
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    exit(0)
                }
            }
            
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            present(alert, animated: false, completion: nil)
            break
            
        case .notDetermined:
            print("notDetermined")
            break
            
        case .denied:
            print("denied")
            let alert = UIAlertController(title: "Request location permission", message:"Please go to 'Settings -> PocketSong -> Allow location access'", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "Allow", style: .default) { (action) in
                if let url = URL(string: "App-prefs:"){
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
            let cancelAction = UIAlertAction(title: "Don't allow", style: .cancel) { (action) in
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    exit(0)
                }
            }

            alert.addAction(cancelAction)
            alert.addAction(okAction)
            
            present(alert, animated: false, completion: nil)
            break
        }
    }
}
