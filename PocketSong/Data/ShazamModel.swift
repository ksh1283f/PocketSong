//
//  ShazamModel.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 12/13/21.
//

import Foundation

struct ShazamModel{
    let coverUrl: URL?
    let artist: String?
    let artworkURL: URL?
    let title: String?
    let appleMusicURL : URL?
    
    let addressInfo:String?
    
    // below variables: if it could get..
    
    
    init(coverUrl:URL?, artist:String?, artworkURL:URL?, title: String?, appleMusicURL: URL?, addressInfo:String?){
        self.coverUrl = coverUrl
        self.artist = artist
        self.artworkURL = artworkURL
        self.title = title
        self.appleMusicURL = appleMusicURL
        self.addressInfo = addressInfo
    }
}
