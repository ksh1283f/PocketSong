//
//  DataController.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 1/25/22.
//

import Foundation
import SQLite3
import CoreLocation

class DataController {
    static let shared = DataController()
    var dataList:[RecordData] = []
    
    var db : OpaquePointer?
    let TABLE_NAME = "UserRecord"
    
    private init() {}
    
    func openDatabase() -> OpaquePointer?{
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("UserRecordDB.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) == SQLITE_OK{
            print("[DataController] Database is opened successfully")
            return db
        }else {
            print("[DataController] Database open failed")
            return nil
        }
    }
    
    func createTable(){
        guard let _db = openDatabase() else {
            print("[DataController] db open failed")
            return
        }
        
        let createQuery = "CREATE TABLE IF NOT EXISTS \(TABLE_NAME) (id INTEGER PRIMARY KEY AUTOINCREMENT, Comment TEXT, CoverURL TEXT Artist TEXT, ArtworkURL TEXT, Title TEXT, AppleMusicURL TEXT, Country TEXT, Locality TEXT, AdministrativeArea TEXT, Street TEXT, CreatedTimeData TEXT, Latitude REAL, Longitude REAL, AddressInfo TEXT)"
        
        if sqlite3_exec(_db, createQuery, nil, nil, nil) != SQLITE_OK{
            let errMsg = String(cString: sqlite3_errmsg(db))
            print("[DataController] creating db table was failed")
        }
        
        var createTableStatement: OpaquePointer?
        
        if sqlite3_prepare(_db, createQuery, -1, &createTableStatement, nil) == SQLITE_OK{
            if sqlite3_step(createTableStatement) == SQLITE_DONE{
                print("[DataController] tabel created successfully")
            }else{
                print("[DataController] failed table create")
            }
        }else{
            print("[DataController] CREATE TABLE statement is not prepared")
        }
        // prevent resource leaks
        sqlite3_finalize(createTableStatement)
    }
    
    func insertDataIntoUserRecordTable(recordData:RecordData?){
        guard let _db = openDatabase() else {
            print("[DataController] db open failed")
            return
        }
        
        if let targetRecordData = recordData, let targetLocationModel = targetRecordData.locationData, let targetShazamModel = targetRecordData.shazamData {
            // let insertQuery:String = "INSERT INTO \(TABLE_NAME) (Comment, CoverURL, ArtworkURL, Title, AppleMusicURL, Country, Locality, AdministrativeArea, Street, CreatedTimeData, Latitude, Longitude, AddressInfo) c
            // VALUES(\(targetRecordData.comment), \(targetShazamModel.coverUrl), \(targetShazamModel.artworkURL), \(targetShazamModel.title), \(targetShazamModel.appleMusicURL), \(targetLocationModel.Country) \(targetLocationModel.Locality) \(targetLocationModel.AdministrativeArea) \(targetLocationModel.Street) \(targetLocationModel.createdTimeString) \(targetLocationModel.latitude) \(targetLocationModel.longitude) \(targetLocationModel.addressInfo)"
            let insertQuery:String = "INSERT INTO \(TABLE_NAME) (Comment, CoverURL, ArtworkURL, Title, ApplieMusicURL, Country, Locality, AdministrativeArea, Street, CreatedTimeData, Latitude, Longitude, AddressInfo) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
            
            var insertStatement: OpaquePointer?
            
            
            
            if sqlite3_prepare_v2(_db, insertQuery, -1, &insertStatement, nil) == SQLITE_OK{
                sqlite3_bind_text(insertStatement, 1, targetRecordData.comment, -1, nil)
                sqlite3_bind_text(insertStatement, 2, targetShazamModel.coverUrl?.absoluteString, -1, nil)
                sqlite3_bind_text(insertStatement, 3, targetShazamModel.artworkURL?.absoluteString, -1, nil)
                sqlite3_bind_text(insertStatement, 4, targetShazamModel.title, -1, nil)
                sqlite3_bind_text(insertStatement, 5, targetShazamModel.appleMusicURL?.absoluteString, -1, nil)
                sqlite3_bind_text(insertStatement, 6, targetLocationModel.country, -1, nil)
                sqlite3_bind_text(insertStatement, 7, targetLocationModel.locality, -1, nil)
                sqlite3_bind_text(insertStatement, 8, targetLocationModel.administrativeArea, -1, nil)
                sqlite3_bind_text(insertStatement, 9, targetLocationModel.street, -1, nil)
                sqlite3_bind_text(insertStatement, 10, targetLocationModel.createdTimeString, -1, nil)
                sqlite3_bind_text(insertStatement, 11, targetLocationModel.latitude, -1, nil)
                sqlite3_bind_text(insertStatement, 12, targetLocationModel.longitude, -1, nil)
                sqlite3_bind_text(insertStatement, 13, targetLocationModel.addressInfo, -1, nil)
                
            }
        }
        
    }
    
    
    
    func onRecordMusic(locationData:LocationModel, shazamData:ShazamModel, comment:String){
        // latitude, longitude
        let recordData = RecordData(locationData: locationData, shazamData: shazamData, comment: comment)
        dataList.append(recordData)
    }
}
