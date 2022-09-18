//
//  Extensions.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 12/22/21.
//

import Foundation
import UIKit
import CLTypingLabel
import MapKit


extension UILabel{
    
    func playTypingEffect(textValue:String, playingDelay: TimeInterval = 3.0, onEnd:@escaping()->Void){
        // Initialized target uiLabel text to be empty
        self.text = ""

        let effectTask = DispatchWorkItem { [weak self] in
            textValue.forEach{ char in
                DispatchQueue.main.async {  // UI update process must be executed in main thread.
                    self?.text?.append(char)
                }
                Thread.sleep(forTimeInterval: playingDelay*0.01)
            }

            if onEnd != nil{
                onEnd()
            }
        }

        let dispatchQueue:DispatchQueue = .init(label: "typespeed", qos: .userInteractive)
        dispatchQueue.asyncAfter(deadline: .now()+0.05, execute: effectTask)
    }

    /// if loopCount is -1, it means infinity
    func playTypingEffectMultiple(textValue:String, playingDelay: TimeInterval = 3.0, onEnd:@escaping()->Void){
        self.text = ""

        // todo need how to control this task: cancelling
        let effectTask = DispatchWorkItem { [weak self] in
            for _ in 0...15{
                DispatchQueue.main.async{
                    self?.text = ""
                }
                textValue.forEach{ char in
                    DispatchQueue.main.async {
                        self?.text?.append(char)
                    }
                    Thread.sleep(forTimeInterval: playingDelay*0.01)
                }
                Thread.sleep(forTimeInterval: 2)
            }
            if onEnd != nil{
                onEnd()
            }
        }

        let dispatchQueue:DispatchQueue = .init(label: "typeSpeedLoop", qos:.userInteractive)
        dispatchQueue.asyncAfter(deadline: .now()+0.05, execute: effectTask)
    }
}

extension UIViewController{
    func alertDefault(title:String, message:String, alertType:UIAlertController.Style = .alert, onClickedBtn: (()->Void)? = nil){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertType)
        let action = UIAlertAction(title: "Ok", style: .default) { _ in
            onClickedBtn?()
        }
        alertController.addAction(action)
        
        self.present(alertController, animated: true)   // todo add completion
    }
    
    func alertDefault(title:String, message:String, alertType:UIAlertController.Style, buttonText:String, onClickedBtn: (()->Void)? = nil){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: alertType)
        let alertAction = UIAlertAction(title: buttonText, style: .default){ _ in
            onClickedBtn?()
        }
        
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
    }
}

extension UIColor{
    convenience init(red:Int, green:Int, blue:Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(blue >= 0 && blue <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid red component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    public convenience init(hex: Int){
        self.init(red: (hex >> 16) & 0xFF, green: (hex >> 8) & 0xFF, blue: hex & 0xFF)
    }
    
    convenience init(hex: String, alpha:CGFloat=1.0){
        var hexFormatted:String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if hexFormatted.hasPrefix("#"){
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: alpha)
    }
}

extension MKMapView{
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000){
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
        
        // for test function
        //makePin(targetCoordinate: location.coordinate)
    }
    
    func makePin(recordData: RecordData){
        guard let coordinate = recordData.locationData else{
            print("[MyMemoriesVC] location data is nil")
            return
        }
        
        // todo need to caching
        
        let pin = MyMemoryAnnotation(recordData: recordData, coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude!, longitude: coordinate.longitude!))

        
        
        self.addAnnotation(pin)
    }
}

extension UIView {
    /// MARK:-  make corner rounded shape
    func roundCorners(cornerRadius:CGFloat, maskedCorners:CACornerMask) {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = CACornerMask(arrayLiteral: maskedCorners)
    }
}

extension UIImage{
    func resizeImage(size:CGSize) -> UIImage?{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func circlized() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let renderer = UIGraphicsImageRenderer(size:rect.size)
        let result = renderer.image{ c in
            let isPortrait = size.height > size.width
            let isLandscape = size.width > size.height
            let breadth = min(size.width, size.height)
            let breadthSize = CGSize(width: breadth, height: breadth)
            let breadthRect = CGRect(origin: .zero, size: breadthSize)
            let origin = CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait ? floor((size.height - size.width) / 2) : 0)
            let circle = UIBezierPath(ovalIn: breadthRect)
            circle.addClip()
            if let cgImage = self.cgImage?.cropping(to: CGRect(origin: origin, size: breadthSize)){
                UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation).draw(in: rect)
            }
            
        }
        return result
    }
}
