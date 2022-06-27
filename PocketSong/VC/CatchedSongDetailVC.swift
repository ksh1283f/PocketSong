//
//  CatchedSongDetailVC.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 12/23/21.
//

import UIKit

class CatchedSongDetailVC: UIViewController, UITextFieldDelegate {
    
    var shazamData:ShazamModel?
    var locationData:LocationModel?
    
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var commetTextField: UITextField!
    
    var isRecorded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commetTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        btnRecord.setTitle("Record", for: .normal)
        self.hideKeyboardWhenTappedAround()
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
            DispatchQueue.main.async {
                if let cover = coverImage{
                    self.songImageView.image = UIImage(data: cover)
                } else {
                    // todo show default image
                }
                
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
        
        if let catchedLocationData = locationData{
            DispatchQueue.main.async {
                // country, city, locality,
                if let addressInfo = catchedLocationData.addressInfo{
                    self.locationLabel.text = addressInfo
                }
            }
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
        self.view.frame.origin.y = -300
    }
    
    @objc func keyboardWillHide(_ sender: Notification){
        self.view.frame.origin.y = 0
        
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
    
}
