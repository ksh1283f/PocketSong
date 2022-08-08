//
//  RecordSongCell.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 6/19/22.
//

import UIKit

class RecordSongCell: UICollectionViewCell {
    
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        songImage.layer.cornerRadius = 12
    }
    
    func setCell(image:UIImage, title:String){
        self.songImage.image = image
        self.songTitle.text = title
    }
}
