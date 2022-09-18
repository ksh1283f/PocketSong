//
//  CatchedSongDetailVC.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 12/23/21.
//

import UIKit
import MapKit
import Kingfisher

class CatchedSongDetailVC: UIViewController, UITextFieldDelegate {
    
    var shazamData:ShazamModel?
    var locationData:LocationModel?
    
    @IBOutlet weak var contentsView: UIView!
    @IBOutlet weak var contentsScrollView: UIScrollView!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var commetTextField: UITextField!
    
    @IBOutlet weak var locationMapView: MKMapView!
    
    var isRecorded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commetTextField.delegate = self
        locationMapView.delegate = self
        self.locationMapView.register(MyMemoryAnnotationView.self, forAnnotationViewWithReuseIdentifier: MyMemoryAnnotationView.identifier)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
       
        
        btnRecord.setTitle("Record", for: .normal)
        self.hideKeyboardWhenTappedAround()
        commetTextField.keyboardType = .default
        commetTextField.returnKeyType = UIReturnKeyType.done
        self.locationMapView.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("CatchedSongDetailVC is will Appear")
        isRecorded = false
        
        if let catchedShazamData = shazamData {
            var coverImage:Data?
            var titleText:String?
            var artistText:String?
            
            // cover image
//            if let coverUrl = catchedShazamData.coverUrl{
            if let artworkUrl = catchedShazamData.artworkURL{
                if let coverImageData = try? Data(contentsOf: artworkUrl){
                        print("\(artworkUrl)")
                        coverImage = coverImageData
                }
            }
            
            // title
            if let titleData = catchedShazamData.title{
                titleText = titleData
            }
            
            // artist
            if let artistData = catchedShazamData.artist{
                artistText = artistData
            }
            
            // Update ui elements
            guard let artworkUrl = catchedShazamData.artworkURL else{ return }
            let scale = UIScreen.main.scale
            let resizeProcesspr = ResizingImageProcessor(referenceSize: CGSize(width: songImageView.bounds.width*scale, height: songImageView.bounds.height * scale), mode: .aspectFit) |> RoundCornerImageProcessor(cornerRadius: 20)
            self.songImageView.kf.setImage(with: artworkUrl, placeholder: nil, options: [.transition(.fade(0.5)), .forceTransition, .processor(resizeProcesspr), .cacheSerializer(FormatIndicatedCacheSerializer.png)]){ result in
               
            }
            
            DispatchQueue.main.async {
                if let title = titleText{
                    self.songTitleLabel.text = title
                } else {
                    self.songTitleLabel.text = ""
                }
                
                if let artist = artistText{
                    self.songArtistLabel.text = artist
                } else {
                    self.songArtistLabel.text = ""
                }
                
                
            }
        } else {
            print("[CatchedSongDetailVC] catchedShazamData is nil")
        }
        
        // MARK:- make pin
        if let ld = locationData, let sd = shazamData{
            locationMapView.makePin(recordData: RecordData(locationData: ld, shazamData: sd))
        }
        
        if let catchedLocationData = locationData{
            DispatchQueue.main.async {
                // country, city, locality,
                if let addressInfo = catchedLocationData.addressInfo{
                    self.locationLabel.text = addressInfo
                }
            }
        }
        
        if CLLocationManager.locationServicesEnabled(){
            LocationController.shared.setupLocationManager(delegate: self)
            checkLocationAuthorization()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        shazamData = nil
        locationData = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("[CatchedSongDetailVC] touchesBegan")
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
        
    }
    
    @IBAction func onClickedBtnRecord(_ sender: Any) {
        // todo save data into the database
        if isRecorded{
            self.alertDefault(title: "Already recorded", message: "already your music was recorded!")
            return
        }
        
        if let presentLocation = self.locationData, let presentShazam = self.shazamData {
            do{
                let dataController = try DataController.open()  // UserRecord table
                let newRecordTable = UserRecordTable(createdTimeData: presentLocation.createdTimeString ?? "Unknown", comment: commetTextField.text ?? "Unknown", coverURL: presentShazam.coverUrl?.description ?? "Unknown", artist: presentShazam.artist ?? "Unknown", artworkURL: presentShazam.artworkURL?.description ?? "Unknown", title: presentShazam.title ?? "Unknown", appleMusicURL: presentShazam.appleMusicURL?.absoluteString ?? "Unknown", country: presentLocation.country ?? "Unknown", locality: presentLocation.locality ?? "Unknown", administrativeArea: presentLocation.administrativeArea ?? "Unknown", street: presentLocation.street ?? "Unknown", latitude: Float(presentLocation.latitude ?? -1), longitude: Float(presentLocation.longitude ?? -1), addressInfo: presentLocation.addressInfo ?? "Unknown")
                
                try dataController.insertData(userRecordTable: newRecordTable)
                
                // todo convert this view to myMemoryView
                self.navigationController?.popViewController(animated: true)
                self.tabBarController?.selectedIndex = 0;
                
            } catch{
                print("[CatchedSongDetailVC] INSERT DATA FAILED!")
            }
            
        }
        
        // todo createMarker on the MyMemoryVC
        self.alertDefault(title: "Record success!", message: "Record the music successfully")
    }
    
    @objc func keyboardWillShow(_ sender: Notification){
        self.contentsView.frame.origin.y = -300
    }
    
    @objc func keyboardWillHide(_ sender: Notification){
        self.contentsView.frame.origin.y = 0
        
    }
}

extension CatchedSongDetailVC{
    func hideKeyboardWhenTappedAround(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func checkLocationAuthorization() {
        switch LocationController.shared.locManager.authorizationStatus{
        case .authorizedAlways:
            locationMapView.showsUserLocation = true
            if let presentLocation = LocationController.shared.locManager.location{
                setupMapViewWithCurrentPosition(presentLocation)
            }else{
                // show alert this situation is invalid
                let alert = UIAlertController(title: "Authorization is need!", message: "Please go to Settings -> Pocketsong then activate location and microphone access", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
                    if let url = URL(string: "App-prefs:"){
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                })
                self.present(alert, animated: true, completion: nil)
            }
            break

        case .authorizedWhenInUse:
            // do map stuff
            locationMapView.showsUserLocation = true
            if let presentLocation = LocationController.shared.locManager.location{
                setupMapViewWithCurrentPosition(presentLocation)
            }else{
                // show alert this situation is invalid
                let alert = UIAlertController(title: "Authorization is need!", message: "Please go to Settings -> Pocketsong then activate location and microphone access", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
                    if let url = URL(string: "App-prefs:"){
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
                if let url = URL(string: "App-prefs:"){
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
                if let url = URL(string: "App-prefs:"){
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            self.present(alert, animated: true, completion: nil)
            break
        }
    }
    
    func setupMapViewWithCurrentPosition(_ location:CLLocation){
        locationMapView.centerToLocation(location)
    }
}

extension CatchedSongDetailVC : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MyMemoryAnnotation else { return nil}
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MyMemoryAnnotationView.identifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: MyMemoryAnnotationView.identifier)
            annotationView?.canShowCallout = true
            annotationView?.contentMode = .scaleAspectFit
        } else{
            annotationView?.annotation = annotation
        }
        
        print("---[CatchedSongDetailVC] AnnotationView bounds \(annotationView?.bounds.width) \(annotationView?.bounds.height)")
        
        if let sd = shazamData, let ld = locationData{
            let scale = UIScreen.main.scale
            let resizeProcessor = ResizingImageProcessor(referenceSize: CGSize(width: annotationView!.bounds.width*scale*0.5, height: annotationView!.bounds.height*scale*0.5)) |> RoundCornerImageProcessor(cornerRadius: 30)
            
            guard let artwork = sd.artworkURL else{return nil}
            
            
            
            ImageCache.default.retrieveImage(forKey: artwork.absoluteString
                                             , options: [.processor(resizeProcessor), .cacheSerializer(FormatIndicatedCacheSerializer.png), .scaleFactor(2.0)]){ result in
                switch result {
                case .success(let value):
                    if let image = value.image {
                        annotationView?.image = image
                        
                    } else {
                        let resource = ImageResource(downloadURL: artwork, cacheKey: artwork.absoluteString)
                        KingfisherManager.shared.retrieveImage(with: resource, options: [.processor(resizeProcessor), .cacheSerializer(FormatIndicatedCacheSerializer.png), .scaleFactor(2.0)], progressBlock: nil,  downloadTaskUpdated:  nil) { result in
                            switch result {
                            case .success(let value):
                                annotationView?.image = value.image
                                
                            case .failure(let error):
                                annotationView?.image = UIImage(systemName: "music.note")
                            }
                            
                        }
                    }
                    
                case .failure(let error):
                    annotationView?.image = UIImage(systemName: "music.note")
                        
                }
            }
            //annotationView?.clipsToBounds = true
            annotationView?.layer.cornerRadius = 20
        }
        
        return annotationView
    }
}

extension CatchedSongDetailVC : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
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
}
