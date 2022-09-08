//
//  ImageCacheManager.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 8/10/22.
//

import Foundation
import Kingfisher
import UIKit

class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private init(){}
    
    func setImage(uiImage: inout UIImage, sourceUrl:String){
        
//        ImageCache.default.retrieveImage(forKey: sourceUrl, options: nil) { result in
//            switch result{
//            case .success(let value):
//                if let image = value.image {
//                    uiImage = image
//                }else{
//                    guard let url = URL(string: sourceUrl) else { return }
//                    let resource = ImageResource(downloadURL: url, cacheKey: sourceUrl)
//                    KingfisherManager.shared.retrieveImage(with: resource){ result in
//                        switch result{
//                        case .success(let value):
//                            uiImage = value.image
//
//                        case .failure(let error):
//                            print(error)
//                        }
//                    }
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
    }
    
    private func checkCurrentCacheSize(){
        ImageCache.default.calculateDiskStorageSize { result in
            switch result{
            case .success(let size):
                print("[ImageCacheManager] current cacheSize: \(Double(size) / 1024 / 1024)")
            case .failure(let error):
                print("[ImageCacheManager] fail: \(error)")
                self.removeCache(isAll: false)
            }
        }
    }
    
    private func removeCache(isAll:Bool){
        if isAll {
            ImageCache.default.clearMemoryCache()
            ImageCache.default.clearDiskCache{
                print("[ImageCacheManager] removed all disk cache")
            }
        }else{
            ImageCache.default.cleanExpiredMemoryCache()
            ImageCache.default.cleanExpiredDiskCache{
                print("[ImageCacheManager] removed expired disk cache")
            }
        }
    }
}
