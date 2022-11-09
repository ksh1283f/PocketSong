//
//  Types.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 4/19/22.
//

import Foundation

enum E_NetworkStateType:String {
    case none = "none"
    case cellular = "cellular"
    case wifi = "wifi"
    case disconnected = "disconnected"
    
    func getMessage() {
        switch self {
        case .cellular:
            print("network connected on cellular")
            
        case .wifi:
            print("network connected on wifi")
            
        case .disconnected:
            print("network is disconnected state")
            
        default:
            print("not initilized network state")
        }
    }
}

enum EmojiType:String, CaseIterable{
    case rockAndRoll = "🤟"
    case sound = "🔊"
    case control = "🎛"
    case saxophone = "🎷"
    case guitar = "🎸"
    case staff = "🎼"
    case piano = "🎹"
    case drum = "🥁"
    case mic = "🎤"
    case headPhone = "🎧"
    
    static func getRandomEmoji() -> String {
        let randomIndex = Int.random(in: 0..<EmojiType.allCases.count)
        return EmojiType.allCases[randomIndex].rawValue
    }
}

struct LocalizeText{
    //static let
    // MARK:- Common
    static let RecognizingFailedErrMsg = "RecognizingFailedErrMsg".localized()
    static let Ok = "Ok".localized()
    static let NetworkDisconnectedTitle = "NetworkDisconnectedTitle".localized()
    static let NetworkDisconnectedMsg = "NetworkDisconnectedMsg".localized()

    static let AuthorizationRequiredTitle = "AuthorizationRequiredTitle".localized()
    static let AuthorizationRequiredMsg = "AuthorizationRequiredMsg".localized()

    static let LocationPermissionTitle = "LocationPermissionTitle".localized()
    static let LocationPermissionMsg = "LocationPermissionMsg".localized()
    static let Allow = "Allow".localized()
    static let DontAllow = "DontAllow".localized()

    // MARK:- Onboarding
    static let PocketsongMyMemoriesDesc = "PocketsongMyMemoriesDesc".localized()
    static let PocketSongCatchSong = "PocketSongCatchSong".localized()
    static let PocketsongSongs = "PocketsongSongs".localized()
    static let Next = "Next".localized()

    // MARK:- Main
    static let SongInfoTitle = "SongInfoTitle".localized()
    static let LocationAndCreatedTimeTitle = "LocationAndCreatedTimeTitle".localized()
    static let CommentTitle = "CommentTitle".localized()
    static let DeleteThisRecordBtnText = "DeleteThisRecordBtnText".localized()

    static let CatchSongNavigationTitle = "CatchSongNavigationTitle".localized()
    static let CatchBtnText = "CatchBtnText".localized()

    static let SongListNavigationTitle = "SongListNavigationTitle".localized()

    static let RecognizingFailedTitle = "Recognizing failed!".localized()

    static let BtnRecordTitle = "BtnRecordTitle".localized()
    static let AlreadyRecordedTitle = "AlreadyRecordedTitle".localized()
    static let AlreadyRecordedMsg = "AlreadyRecordedMsg".localized()
    static let RecordSuccessTitle = "RecordSuccessTitle".localized()
    static let RecordSuccessMsg = "RecordSuccessMsg".localized()

    static let NoMusicUrlTitle = "NoMusicUrlTitle".localized()
    static let AppleMusicUrlMsg = "AppleMusicUrlMsg".localized()
    static let NoticeTitle = "NoticeTitle".localized()
    static let NoticeMsg = "NoticeMsg".localized();
}
