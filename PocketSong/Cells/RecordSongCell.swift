//
//  RecordSongCell.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 6/19/22.
//

import UIKit
import Kingfisher

class RecordSongCell: UICollectionViewCell {
    
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    
    var imageUrl:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        songImage.layer.cornerRadius = 12
    }
    
    func setCell(image:UIImage, title:String){
        self.songImage.image = image
        self.songTitle.text = title
    }
    
    func setCellData(imageUrl: String, title: String){
        self.imageUrl = imageUrl
        print("[recprdSongCell] imageurl: \(imageUrl)")
        self.songTitle.text = title
        
        
        DispatchQueue.main.async {
            let resource = ImageResource(downloadURL: URL(string: self.imageUrl)!, cacheKey: self.imageUrl)
            self.songImage.kf.setImage(with: resource)
        }
        
    }
}
