//
//  DataController.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 1/25/22.
//

import Foundation
import SQLite3
import CoreLocation

enum SQLiteError: Error{
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

class DataController {
    private let db : OpaquePointer?
    let TABLE_NAME = "UserRecord"
    var dataList:[RecordData] {
        get {
                if let allUsers = getAllUserRecord() {
                    return allUsers
            }
            
            return [RecordData]()
        }
        set{
            dataList = newValue
        }
    }
    
    static let dbInitPath = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    static let dbFinalPath = dbInitPath?.appendingPathComponent("UserRecord.sqlite").relativePath
    
    private init(dbPointer:OpaquePointer?) {
        self.db = dbPointer
    }
    deinit{
        sqlite3_close(self.db)
    }
    
    static func open() throws -> DataController{
        var db:OpaquePointer?
        print("[dataController] \(dbFinalPath)")
        if sqlite3_open(dbFinalPath, &db) == SQLITE_OK{
            return DataController(dbPointer: db)
        }else{
            defer{
                if db != nil{
                    sqlite3_close(db)
                }
            }
            if let errorPointer = sqlite3_errmsg(db){
                let message = String(cString: errorPointer)
                throw SQLiteError.OpenDatabase(message: message)
            }else{
                throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite")
            }
        }
    }
    
    static func open(path:String) throws -> DataController{
        var db:OpaquePointer?
        
        if sqlite3_open(path, &db) == SQLITE_OK{
            
            return DataController(dbPointer: db)
        }else{
            defer{
                if db != nil{
                    sqlite3_close(db)
                }
            }
            if let errorPointer = sqlite3_errmsg(db){
                let message = String(cString: errorPointer)
                throw SQLiteError.OpenDatabase(message: message)
            }else{
                throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite")
            }
        }
    }
    
    fileprivate var errorMessage:String{
        if let errorPointer = sqlite3_errmsg(self.db){
            let errorMessage = String(cString: errorPointer)
            return errorMessage
        } else{
            return "No error message provided from sqlite"
        }
    }
    
    func onRecordMusic(locationData:LocationModel, shazamData:ShazamModel, comment:String){
        // latitude, longitude
        let recordData = RecordData(locationData: locationData, shazamData: shazamData, comment: comment)
        dataList.append(recordData)
    }
    
}

extension DataController{
    func prepareStatement(sql: String) throws -> OpaquePointer?{
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else{
            throw SQLiteError.Prepare(message: errorMessage)
        }
        return statement
    }
    
    func createTable(table: SQLTable.Type) throws {
        let createTableStatement = try prepareStatement(sql: table.createStatement)
        
        defer{
            sqlite3_finalize(createTableStatement)
        }
        
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else{
            throw SQLiteError.Step(message: errorMessage)
        }
        print("[DataController] \(table) table created")
    }
    
    func insertData(userRecordTable:UserRecordTable) throws{
        let insertSql = UserRecordTable.insertStatement
        let insertStatement = try prepareStatement(sql: insertSql)
        defer{
            sqlite3_finalize(insertStatement)
        }
        
        let createdTimeData = userRecordTable.createdTimeData ?? ""
        let comment = userRecordTable.comment ?? ""
        let coverUrl = userRecordTable.coverURL ?? ""
        let artist = userRecordTable.artist ?? ""
        let artworkUrl = userRecordTable.artworkURL ?? ""
        let title = userRecordTable.title ?? ""
        let appleMusicUrl = userRecordTable.appleMusicURL ?? ""
        let country = userRecordTable.country ?? ""
        let locality = userRecordTable.locality ?? ""
        let administrativeArea = userRecordTable.administrativeArea ?? ""
        let street = userRecordTable.street ?? ""
        let latitude = userRecordTable.latitude ?? 0.0
        let longitude = userRecordTable.longitude ?? 0.0
        let addressInfo = userRecordTable.addressInfo ?? ""
        
        guard
            sqlite3_bind_text(insertStatement, 1, NSString(string: createdTimeData).utf8String,-1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 2, NSString(string: comment).utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 3, NSString(string: coverUrl).utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 4, NSString(string: artist).utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 5, NSString(string: artworkUrl).utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 6, NSString(string: title).utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 7, NSString(string: appleMusicUrl).utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 8, NSString(string: country).utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 9, NSString(string: locality).utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 10, NSString(string: administrativeArea).utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 11, NSString(string: street).utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_double(insertStatement, 12, Double(latitude)) == SQLITE_OK &&
            sqlite3_bind_double(insertStatement, 13, Double(longitude)) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 14, NSString(string: addressInfo).utf8String, -1, nil) == SQLITE_OK
        else{
            throw SQLiteError.Bind(message: errorMessage)
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        print("[DataController] Successfully inserted data")
    }
    
    private func getAllUserRecord() -> [RecordData]? {
        var result:[RecordData] = []
        let sql  = "SELECT * FROM \(self.TABLE_NAME);"
        guard let queryStatement = try? prepareStatement(sql: sql) else {
            return nil
        }
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        while sqlite3_step(queryStatement) == SQLITE_ROW {
            guard let createdTime = sqlite3_column_text(queryStatement, 0) else {
                print("[DataController:sqlite3_step] createdTime is nil")
                return nil}
            print("[DataController:sqlite3_step] createdTime is \(String(cString: createdTime))")
            guard let comment = sqlite3_column_text(queryStatement, 1) else {
                print("[DataController:sqlite3_step] comment is nil")
                return nil }
            print("[DataController:sqlite3_step] comment is \(String(cString: comment))")
            guard let coverUrl = sqlite3_column_text(queryStatement, 2) else {
                print("[DataController:sqlite3_step] coverUrl is nil")
                return nil }
            print("[DataController:sqlite3_step] coverUrl is \(String(cString: coverUrl))")
            guard let artist = sqlite3_column_text(queryStatement, 3) else {
                print("[DataController:sqlite3_step] artist is nil")
                return nil }
            guard let artworkUrl = sqlite3_column_text(queryStatement, 4) else {
                print("[DataController:sqlite3_step] artworkUrl is nil")
                return nil }
            
            guard let title = sqlite3_column_text(queryStatement, 5) else {
                print("[DataController:sqlite3_step] artworkUrl is nil")
                return nil }
            guard let appleMusicUrl = sqlite3_column_text(queryStatement, 6) else {
                print("[DataController:sqlite3_step] appleMusicUrl is nil")
                return nil }
            guard let country = sqlite3_column_text(queryStatement, 7) else {
                print("[DataController:sqlite3_step] country is nil")
                return nil }
            guard let locality = sqlite3_column_text(queryStatement, 8) else {
                print("[DataController:sqlite3_step] locality is nil")
                return nil }
            guard let administrativeArea = sqlite3_column_text(queryStatement, 9) else {
                print("[DataController:sqlite3_step] administrativeArea is nil")
                return nil }
            guard let street = sqlite3_column_text(queryStatement, 10) else {
                print("[DataController:sqlite3_step] street is nil")
                return nil }
            let latitude = sqlite3_column_double(queryStatement, 11)
            let longitude  = sqlite3_column_double(queryStatement, 12)
            
            guard let addressInfo = sqlite3_column_text(queryStatement, 13) else {
                print("[DataController:sqlite3_step] addressInfo is nil")
                return nil }
            
            // 1. create locationData
//            let timeData = LocationModel.ToString(date: String(cString: createdTime)) ?? Date()
            
            var timeData = LocationModel.ToString(date: String(cString: createdTime))
            if  timeData == nil{
                timeData = Date()
                print("timeData is nil. so it will be initialized present date")
            }
            
            
            let locationData = LocationModel(country: String(cString: country), administrativeArea: String(cString: administrativeArea), locality: String(cString: locality), street: String(cString: street), timeData: timeData!, latitude: latitude, longitude: longitude)

            // 2. create shazamData
            let shazamData = ShazamModel(coverUrl: URL(string: String(cString: coverUrl)), artist: String(cString: artist), artworkURL: URL(string: String(cString: artworkUrl)), title: String(cString: title), appleMusicURL: URL(string: String(cString:appleMusicUrl)), addressInfo: String(cString: addressInfo))
            
            let recordData = RecordData(locationData: locationData, shazamData: shazamData, comment: String(cString: comment))
            
            result.append(recordData)
        }
        
        return result
    }
    
    func updateData(dataKey:String, column:String, newValue:String,condition: String) throws{
        let sql = "UPDATE UserRecord SET \(column) = \(newValue) WHERE = \(condition);"
        let queryStatement = try prepareStatement(sql: sql)
        defer{
            sqlite3_finalize(queryStatement)
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_DONE else{
            throw SQLiteError.Step(message: errorMessage)
        }
    }
    
    func deleteData(dataKey:String, condition:String) throws {
        let sql = "DELETE FROM UserRecord WHERE \(dataKey) == \'\(condition)\';"
        let queryStatement = try? prepareStatement(sql: sql)
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_DONE else{
            throw SQLiteError.Step(message: errorMessage)
        }
        
    }
    
}

extension DataController{
    public static func dbOpen(caller:String, process:([RecordData]) -> Void){
        do{
            let dataController = try open()
            process(dataController.dataList)
        }catch SQLiteError.OpenDatabase(_){
            print("\(caller) DataController open Failed")
        }catch SQLiteError.Step(_){
            print("\(caller) DataController step Failed")
        }catch{
            print("\(caller) DataController failed")
        }
    }
}

//let db: DataController
//do {
//    db = try DataController.open(path: "UserRecordDB.sqlite")
//    print("open successfully")
//} catch SQLiteError.OpenDatabase(_){
//    print("unable to open database")
//}
