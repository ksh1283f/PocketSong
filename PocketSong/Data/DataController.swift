//
//  DataController.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 1/25/22.
//

import Foundation
import SQLite3
import CoreLocation

class DataController{
    static let shared = DataController()
    var dataList:[RecordData] = []
    
    var db : OpaquePointer?
    let TABLE_NAME = "UserRecord"
    
    private init() {}
    
    func initDB(){
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("UserRecordDB.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) == SQLITE_OK{
            print("[DataController] Database table is not exist")
        }
        
        let createQuery = "CREATE TABLE IF NOT EXISTS \(TABLE_NAME) (id INTEGER PRIMARY KEY AUTOINCREMENT, Comment TEXT, CoverURL TEXT Artist TEXT, ArtworkURL TEXT, Title TEXT, AppleMusicURL TEXT, Country TEXT, Locality TEXT, AdministrativeArea TEXT, Street TEXT, CreatedTimeData TEXT, Latitude REAL, Longitude REAL, AddressInfo TEXT)"
        print(fileUrl)
        if sqlite3_exec(db, createQuery, nil, nil, nil) != SQLITE_OK{
            let errMsg = String(cString: sqlite3_errmsg(db))
            print("[DataController] creating db table was failed")
        }
    }
    
    func insertDataIntoUserRecordTable(recordData:RecordData?){
        var stmt: OpaquePointer?
        if let targetRecordData = recordData, let targetLocationModel = targetRecordData.locationData, let targetShazamModel = targetRecordData.shazamData {
            let insertQuery:String = "INSERT INTO \(TABLE_NAME) (Comment, CoverURL, ArtworkURL, Title, AppleMusicURL, Country, Locality, AdministrativeArea, Street, CreatedTimeData, Latitude, Longitude, AddressInfo) VALUES(\(targetRecordData.comment), \(targetShazamModel.coverUrl), \(targetShazamModel.artworkURL), \(targetShazamModel.title), \(targetShazamModel.appleMusicURL), \(targetShazamModel)"
        }
        
    }
    
    func onRecordMusic(locationData:LocationModel, shazamData:ShazamModel, comment:String){
        // latitude, longitude
        let recordData = RecordData(locationData: locationData, shazamData: shazamData, comment: comment)
        dataList.append(recordData)
    }
}
