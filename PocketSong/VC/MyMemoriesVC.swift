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
import FlyoverKit
import Kingfisher
import BottomHalfModal


class MyMemoriesVC: UIViewController{
    
//    var locManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedAnnotation:MKAnnotation?
    var pinDic:[String:RecordData] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.register(MyMemoryAnnotationView.self, forAnnotationViewWithReuseIdentifier: MyMemoryAnnotationView.identifier)
        self.mapView.register(LocationDataMapClusterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        self.mapView.delegate = self
        
        // test
        self.mapView.mapType = .standard
        self.mapView.showsBuildings = true
        self.mapView.showsScale = true
        self.mapView.showsCompass = true
        self.mapView.showsTraffic = true
        
        self.mapView.showsLargeContentViewer = true
        
//        let testButton = UIButton()
//        testButton.frame = CGRect(x: 10, y: 100, width: 200, height: 100)
//        testButton.layer.backgroundColor = .init(red: 1, green: 0, blue: 0, alpha: 1)
//        testButton.addTarget(self, action: #selector(onClickedTestButton), for: .touchUpInside)
//
//        self.view.addSubview(testButton)
//
//        let testImageView = UIImageView()
//        testImageView.frame = CGRect(x:215, y:215, width: 100, height:100)
//        self.view.addSubview(testImageView)
//
//        let resource = ImageResource.init(downloadURL:URL(string: "https://is2-ssl.mzstatic.com/image/thumb/Music125/v4/7d/ac/83/7dac83f6-dbb0-b7e9-21a1-b0387a5c8f39/00602537201525.rgb.jpg/800x800bb.jpg")!)
//        testImageView.kf.indicatorType = .activity
//        testImageView.kf.setImage(with: resource, options: [.transition(.fade(1.0)), .forceTransition, .keepCurrentImageWhileLoading])
//        testImageView.layer.masksToBounds = true
//        testImageView.layer.cornerRadius = 15
    }
    
    @objc func onClickedTestButton(){
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
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
            self.pinDic.removeAll()
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            for item in $0 {
                updatePinWithData(recordData: item)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.navigationItem.title = ""
        
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
                    
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                   UIApplication.shared.open(url, options: [:], completionHandler: nil)
                               }
                    
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
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                   UIApplication.shared.open(url, options: [:], completionHandler: nil)
                               }
                })
                self.present(alert, animated: true, completion: nil)
            }
            
            break
            
        case .denied:
//             show alert instructing them how to on permissions
            let alert = UIAlertController(title: "Authorization is need!", message: "Please go to Settings -> Pocketsong then activate location and microphone access", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                               UIApplication.shared.open(url, options: [:], completionHandler: nil)
                           }
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
                if let url = URL(string: UIApplication.openSettingsURLString) {
                               UIApplication.shared.open(url, options: [:], completionHandler: nil)
                           }
            })
            self.present(alert, animated: true, completion: nil)
            break
        }
    }
    
    func setupMapViewWithCurrentPosition(_ location:CLLocation){
        mapView.centerToLocation(location)
    }
    
    func updatePinWithData(recordData:RecordData){
        if let ld = recordData.locationData, let createdTime = ld.createdTimeString {
            if pinDic.keys.contains(createdTime) {
                return
            }
            
            pinDic[createdTime] = recordData
            self.mapView.makePin(recordData: recordData)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        self.selectedAnnotation = view.annotation
        if let annotationTitle = view.annotation?.title {
            print("User tapped on annotation with title: \(annotationTitle!)")
        }
        
        if let annotation = view.annotation as? MyMemoryAnnotation, let recordData = annotation.recordData {
            self.performSegue(withIdentifier: "segueToMyMemoryDetail", sender: recordData)
        } else if let annotation = view.annotation as? MKClusterAnnotation {
            print("---[MyMemoriesVC] Clicked cluster annotation \(annotation.memberAnnotations.count)")
            // todo segue or half modal
            showHalfModalFromClusterAnnotation(annotation: annotation)
        }
        
        mapView.deselectAnnotation(view.annotation, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let recordData = sender as? RecordData else { return }
        if let id = segue.identifier, id == "segueToMyMemoryDetail"{
            if let detailVC = segue.destination as? MyInformationDetailVC{
                detailVC.setRecordData(recordData: recordData)
                detailVC.removalDelegate = self
            }
        }
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
//        checkLocationServices()
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

extension MyMemoriesVC : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is MyMemoryAnnotation:
            // dequeue
            guard let annotation = annotation as? MyMemoryAnnotation else{ return nil}

            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MyMemoryAnnotationView.identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: MyMemoryAnnotationView.identifier)
                annotationView?.canShowCallout = true
                annotationView?.contentMode = .scaleAspectFit

            }else{
                annotationView?.annotation = annotation
            }

           annotationView?.clusteringIdentifier = String(describing: MyMemoryAnnotationView.self)
            
            if let recordData = annotation.recordData, let shazamData = recordData.shazamData, let artwork = shazamData.artworkURL{
                let scale = UIScreen.main.scale
                let resizeProcessor = ResizingImageProcessor(referenceSize: CGSize(width: annotationView!.bounds.width*scale*0.5, height: annotationView!.bounds.height*scale*0.5)) |> RoundCornerImageProcessor(cornerRadius: 30)

                
                ImageCache.default.retrieveImage(forKey: artwork.path, options: [.processor(resizeProcessor), .cacheSerializer(FormatIndicatedCacheSerializer.png), .scaleFactor(2.0)]){ result in
                    switch result {
                    case .success(let value):
                        if let image = value.image{
                                annotationView?.image = image
                            print("--- [MyMemoriesVC] ImageCache image received ---")
                        } else {
                            let resource = ImageResource(downloadURL: artwork, cacheKey: artwork.path)
                            KingfisherManager.shared.retrieveImage(with: resource, options: [.processor(resizeProcessor),.cacheSerializer(FormatIndicatedCacheSerializer.png),.scaleFactor(2.0)], progressBlock: nil, downloadTaskUpdated: nil) { result in
                                switch result {
                                case .success(let value):
                                    annotationView?.image = value.image
                                    print("--- [MyMemoriesVC] new image received ---")

                                case .failure(let error):
                                    print("retrieve image failed from url : \(error)")
                                    annotationView?.image = UIImage(systemName: "music.note")
                                }
                            }
                        }

                    case .failure(let error):
                        annotationView?.image = UIImage(systemName: "music.note")
                    }
                }

                annotationView?.layer.cornerRadius = 20
            }
            
            return annotationView

        case is MKClusterAnnotation:
            guard let clusterAnnotation = annotation as? MKClusterAnnotation else { return nil }

            if let clusterAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier, for: clusterAnnotation) as? LocationDataMapClusterView{
                clusterAnnotationView.annotation = clusterAnnotation
                return clusterAnnotationView
            }else{
                
                print("--- [MyMemoriesVC] viewFor created new location data map cluster view---")
                return LocationDataMapClusterView(annotation: clusterAnnotation, reuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
            }
            
        default:
            return nil
        }
    }
}

extension MyMemoriesVC:PostProcessOfRemoveRecord{
    func updateRemoval(isRemoval:Bool) {
        if isRemoval{
            if let selected = self.selectedAnnotation {
                
                self.mapView.removeAnnotation(selected)
                if let selectedMyMemoriesAnnotation = selected as? MyMemoryAnnotation, let record = selectedMyMemoriesAnnotation.recordData, let ld = record.locationData{
                    if let createdTime = ld.createdTimeString{
                        let result = self.pinDic.removeValue(forKey: createdTime)
                        print("[MyMemoriesVC] updateRemoval \(result != nil)")
                    }
                }
                
            }
        }
    }
}

// MARK:- half modal view present
extension MyMemoriesVC {
    func showHalfModalFromClusterAnnotation(annotation: MKClusterAnnotation){
        let annotations = annotation.memberAnnotations.map{ $0 as? MyMemoryAnnotation }.filter{$0 != nil}
        let recordDataList = annotations.map{ $0!.recordData }.filter{ $0 != nil }.map{$0!}
        
        let csVC = ClusteredSongListVC()
        csVC.setCellData(recordDataList: recordDataList, clickEvent: self)
        
        let nav = BottomHalfModalNavigationController(rootViewController: csVC)
        self.presentBottomHalfModal(nav, animated: true, completion: nil)
    }
}

extension MyMemoriesVC : PostProcessCellClickEvent{
    func onClickedBtnCell(recordData: RecordData) {
        self.performSegue(withIdentifier: "segueToMyMemoryDetail", sender: recordData)
    }
}
