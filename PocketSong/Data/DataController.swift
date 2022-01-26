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
    
    private init() {}
    
    func initDB(){
        let path:String = {
            let fm = FileManager.default
            return fm.urls(for: .libraryDirectory, in: .userDomainMask).last!
                .appendingPathComponent("UserRecord.db").path
        }()
        
        let createTableString = """
            CREATE TABLE IF NOT EXISTS UserRecord(
            Id INTEGER PRIMARY KEY AUTOINCREMENT,
            MusicTitle CHAR(255),
            Done INT);
            """
    }
    
    func onRecordMusic(locationData:LocationModel, shazamData:ShazamModel, comment:String){
        // latitude, longitude
        let recordData = RecordData(locationData: locationData, shazamData: shazamData, comment: comment)
        dataList.append(recordData)
    }
}
