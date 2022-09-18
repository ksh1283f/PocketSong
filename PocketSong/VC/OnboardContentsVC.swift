//
//  OnboardContentsVC.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 8/25/22.
//

import UIKit
import Lottie
import SnapKit

class OnboardContentsVC: UIViewController {
    
    @IBOutlet weak var contentsView: UIView!
    @IBOutlet weak var contentsLabel: UILabel!
    
    let animationView = AnimationView()
    var index:Int = 0
    var isAnimationInit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentsView.backgroundColor = UIColor(hex: 0x009051)
        setAni(completion: nil)
        contentsLabel.text = getLabelText(index: self.index)
        
        print("[OnboardingContentsVC] viewDidLoad \(index)")
    }
    
    static func getInstance(idx: Int) -> OnboardContentsVC{
        let vc = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "OnboardContentsVC") as! OnboardContentsVC
        vc.index = idx
        
        
        return vc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("[OnboardContentsVC \(index)] viewWillAppear")
        animationView.reloadImages()
        animationView.play()
        
    }
}

extension OnboardContentsVC{
    private func setAni(completion: ((Bool)->Void)?){
        guard let aniName = getAnimationFileName(index: self.index) else{ return }
        
//        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.animation = Animation.named(aniName)
        animationView.frame = contentsView.bounds
        
        animationView.loopMode = .playOnce
        animationView.backgroundBehavior = .pauseAndRestore
        
        animationView.isUserInteractionEnabled = true
        contentsView.addSubview(animationView)
        animationView.contentMode = .scaleAspectFit
        animationView.snp.makeConstraints{ make in
            make.center.equalTo(contentsView)
            make.centerY.equalTo(contentsView)
            make.size.equalTo(contentsView)
        }
        
        isAnimationInit = true
    }
    
    private func getAnimationFileName(index: Int) -> String?{
        var result = ""
        
        switch index {
        case 0:
            result += "PocketsongMyMemories"
            
        case 1:
            result += "PocketSongCatchSong"
            
        case 2:
            result += "PocketsongSongs"
            
            
        default:
            return nil
        }
        
        return result
    }
    
     private func getLabelText(index: Int) -> String{
        var result = ""
        switch index{
        case 0:
            result = "You can see the detail information of songs you recorded on the map!"
            
        case 1:
            result = "Touch 'Record' button if you want to record a song which is playing around."
            
        case 2:
            result = "This view shows all songs list you recorded at once with table."
            
        default:
            result = ""
        }
        
        return result
    }
}
