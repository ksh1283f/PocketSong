//
//  MyMemoryAnnotationView.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 8/10/22.
//

import Foundation
import MapKit

class MyMemoryAnnotationView : MKAnnotationView{
    static let identifier = "myMemoryAnnotation"
    
    let titleLabel:UILabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?){
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        centerOffset = CGPoint(x:0, y: -frame.size.height / 2)
        backgroundColor = .clear
        
        titleLabel.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(title: String, subtitle:String){
        titleLabel.text = title + "\n" + subtitle
    }
}

class MyMemoryAnnotation : NSObject, MKAnnotation{
    let recordData:RecordData?
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    
    init(recordData: RecordData, coordinate: CLLocationCoordinate2D) {
        self.recordData = recordData
        self.coordinate = coordinate
        self.title = self.recordData?.shazamData?.title
        self.subtitle = self.recordData?.shazamData?.artist
        
        super.init()
    }
}

final class LocationDataMapClusterView: MKAnnotationView{
    override init(annotation: MKAnnotation?, reuseIdentifier:String?){
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        displayPriority = .defaultHigh
        collisionMode = .circle
        
        frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        centerOffset = CGPoint(x:0, y: -frame.size.height / 2)
        
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        if let clusterAnnotation = annotation as? MKClusterAnnotation{
            let count = clusterAnnotation.memberAnnotations.count
            print("[LocationDataCluster] count: \(count)")
            var countString = count > 99 ? "99+" : String(count)
            image = setupUI(memberCount: countString)
        }else{
            print("[LocationDataCluster] count: binding failed")
        }
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(memberCount:String) -> UIImage{
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100))
        return renderer.image{ _ in
            
            let color = UIColor(hex: 0x009051)
            color.setFill()
            UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 40, height: 40)).fill()
            
            color.setFill()
            let triangle = UIBezierPath()
            triangle.move(to: CGPoint(x:0, y:20))
            triangle.addLine(to: CGPoint(x: 40, y: 20))
            triangle.addLine(to: CGPoint(x: 20, y: 60))
            triangle.close()
            triangle.fill()
                
//            let whiteColor = UIColor.white
//            whiteColor.setFill()
//            let piePath = UIBezierPath()
//            piePath.addArc(withCenter: CGPoint(x:20, y:20), radius: 20, startAngle: 0, endAngle: (CGFloat.pi * 2.0 * 1.0) / 3.0, clockwise: true)
//            piePath.addLine(to: CGPoint(x:20, y:20))
//            piePath.close()
//            piePath.fill()
            
            
            let colorIndside = UIColor.white
            colorIndside.setFill()
            UIBezierPath(ovalIn: CGRect(x:6, y:6, width: 28, height:28)).fill()
            
            // text
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: memberCount == "99+" ?  14 : 18)]
            let text:String = memberCount
            let size = text.size(withAttributes: attributes)
            let rect = CGRect(x: 20 - size.width/2, y: 20 - size.height/2, width: size.width, height: size.height)
            text.draw(in: rect, withAttributes: attributes)
        }
    }
}
