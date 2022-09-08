//
//  MyInformationDetailVC.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 8/10/22.
//

import UIKit
import FlyoverKit
import MapKit
import Kingfisher

protocol PostProcessOfRemoveRecord {
    func updateRemoval(isRemoval:Bool)
}

class MyInformationDetailVC: UIViewController {

    @IBOutlet weak var flyoverMapView: MKMapView!
    
    // SongInfoView
    @IBOutlet weak var songInfoView: UIView!
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var btnPlayAppleMusic: UIButton!

    @IBOutlet weak var btnDelete: UIButton!
    
    // addressInfoView
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    
    // commentView
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentLabel: UILabel!
    
    // constants
    let cornerRadiusValue:CGFloat = 12
    var targetRecordData:RecordData?
    var flyerOverCam:FlyoverCamera?
    var position:CLLocationCoordinate2D?
    
    // removal delegate
    var removalDelegate:PostProcessOfRemoveRecord?
    var isremovedRecord:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[MyMemoryInformationDetailVC] viewDidLoad")
        songInfoView.layer.cornerRadius = cornerRadiusValue
        addressView.layer.cornerRadius = cornerRadiusValue
        commentView.layer.cornerRadius = cornerRadiusValue
        
        songImageView.layer.cornerRadius = cornerRadiusValue
        
//        flyoverMapView.isUserInteractionEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let record = targetRecordData{
            setViewInfo(recordData: record)
        }
        
        isremovedRecord = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let fc = self.flyerOverCam, let pos = self.position{
            fc.start(flyover: pos)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removalDelegate?.updateRemoval(isRemoval: isremovedRecord)
    }
    
    func setRecordData(recordData: RecordData){
        self.targetRecordData = recordData
    }
    
    func setViewInfo(recordData: RecordData){
        guard let shazamData = recordData.shazamData else {
            print("[MyInformationDetail] shazamData is nil")
            return }
        
        guard let locationData = recordData.locationData else {
            print("[MyInformationDetail] locationData is nil")
            return }
        
        // 1. setup FlyoverCamera
        let flyoverCamera = FlyoverCamera(mapView: self.flyoverMapView)
        
        let camConfiguration = FlyoverCamera.Configuration(duration: 4.0, altitude: 600.0, pitch: 45.0, headingStep: 20.0, regionChangeAnimation: .animated(duration: 2.0, curve: .easeInOut))
        
        let targetPosition = CLLocationCoordinate2D(latitude: locationData.latitude!, longitude: locationData.longitude!)
        
        flyoverCamera.configuration = camConfiguration
        self.flyerOverCam = flyoverCamera
        self.position = targetPosition
        
        // 2. setup songInfo
        songTitleLabel.text = shazamData.title!
        artistLabel.text = shazamData.artist!
        
        // todo setup image
        guard let artworkUrl = shazamData.artworkURL else {
            print("[MyInformationDetail] artworkUrl is nil")
            return}
        songImageView.kf.setImage(with: artworkUrl)
        
        // address
        addressLabel.text = locationData.addressInfo!
        
        commentLabel.text = recordData.comment!
    }
    
    @IBAction func onClickedBtnPlayAppleMusic(_ sender: Any) {
        if let record = self.targetRecordData{
            if let shazamData = record.shazamData, let appleMusicUrl = shazamData.appleMusicURL {
                if appleMusicUrl.path == "Unknown"{
                    print("--- [MyMInformationDetailVC] url is unknown ---")
                    return
                } else {
                    print("opening apple music...")
                    let appleMusic = "musics://"
                    let url = appleMusicUrl.absoluteString.components(separatedBy: "://")
                    if url.count == 2 {
                        let result = appleMusic + url[1]
                        if UIApplication.shared.canOpenURL(URL(string: result)!){
                            UIApplication.shared.open(URL(string:result)!)
                        }
                    }
                }
            }
        }else {
            self.alertDefault(title: "No Music URL", message: "AppleMusic URL Data isn't exist!", alertType: .alert, buttonText: "Ok")
        }
    }
    
    
    @IBAction func onClickedBtnDelete(_ sender: Any) {
        do{
            let dataController = try DataController.open()  // UserRecord table
            if let targetToDelete = targetRecordData, let ld = targetToDelete.locationData, let key = ld.createdTimeString{
                try dataController.deleteData(dataKey: "createdTimeData", condition: key)

                alertDefault(title: "Notice", message: "The record was deleted successfully", alertType: .alert){
                    self.isremovedRecord = true
                    self.dismiss(animated: true)
                }
            }

        } catch{
            print("[CatchedSongDetailVC] delete DATA FAILED!")
            alertDefault(title: "Notice", message: "There is something problem to delete the record", alertType: .alert){
                self.dismiss(animated: true)
            }
        }
    }
    
}
