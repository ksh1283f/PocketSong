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
            print("catchedShazamData is nil")
        }
        
        if let catchedLocationData = locationData{
            var presentStreetNumber:String?
            var presentStreetName:String?
            var presentCountry:String?
            var presentLocality:String?
            var presentCreatedTimeString:String?
            
            if let streetNumber = catchedLocationData.streetNumber{
                presentStreetNumber = streetNumber
            } else {
                presentStreetNumber = ""
            }
            
            if let streetName = catchedLocationData.streetName{
                presentStreetName = streetName
            } else {
                presentStreetName = ""
            }
            
            if let country = catchedLocationData.country{
                presentCountry = country
            } else {
                presentCountry = ""
            }
            
            if let locality = catchedLocationData.locality{
                presentLocality = locality
            } else {
                presentLocality = ""
            }
            
            if let time = catchedLocationData.createdTimeString{
                presentCreatedTimeString = time
            } else {
                presentCreatedTimeString = ""
            }
            
            //todo create location text
                
            DispatchQueue.main.async {
                
                locationLabel.text =
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
        // todo createMarker on the MyMemoryVC
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
