//
//  UserRecordTable.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 2/28/22.
//

import Foundation

struct UserRecordTable: SQLTable {

    let createdTimeData: String?
    let comment : String?
    let coverURL: String?
    let artist: String?
    let artworkURL : String?
    let title: String?
    let appleMusicURL : String?
    let country : String?
    let locality : String?
    let administrativeArea: String?
    let street : String?
    let latitude : Float?
    let longitude:Float?
    let addressInfo:String?
    
    init(createdTimeData: String, comment : String,coverURL:String, artist:String,artworkURL : String, title:String,appleMusicURL : String, country : String, locality : String, administrativeArea: String, street : String, latitude : Float, longitude:Float, addressInfo:String) {
        
        self.createdTimeData = createdTimeData
        self.comment = comment
        self.coverURL = coverURL
        self.artist = artist
        self.artworkURL = artworkURL
        self.title = title
        self.appleMusicURL = appleMusicURL
        self.country = country
        self.locality = locality
        self.administrativeArea = administrativeArea
        self.street = street
        self.latitude = latitude
        self.longitude = longitude
        self.addressInfo = addressInfo
    }
    
    
}

extension UserRecordTable{
    static var createStatement: String{
        return """
            CREATE TABLE IF NOT EXISTS UserRecord(
                CreatedTimeData TEXT PRIMARY KEY,
                Comment TEXT,
                CoverURL TEXT,
                Artist TEXT,
                ArtworkURL TEXT,
                Title TEXT,
                AppleMusicURL TEXT,
                Country TEXT,
                Locality TEXT,
                AdministrativeArea TEXT,
                Street TEXT,
                Latitude REAL,
                Longitude REAL,
                AddressInfo TEXT
            );
        """
    }
    
    static var insertStatement: String{
        return """
            INSERT INTO UserRecord (
                    CreatedTimeData,
                    Comment,
                    CoverURL,
                    Artist,
                    ArtworkURL,
                    Title,
                    AppleMusicURL,
                    Country,
                    Locality,
                    AdministrativeArea,
                    Street,
                    Latitude,
                    Longitude,
                    AddressInfo
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
"""
    }
}

protocol SQLTable{
    static var createStatement: String { get }
}
