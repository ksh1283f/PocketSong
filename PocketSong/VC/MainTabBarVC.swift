//
//  MainTabBarVC.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 12/5/21.
//

import UIKit

class MainTabBarVC: UITabBarController  {

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension MainTabBarVC:UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("[tabBarController] didSelect \(viewController)")
    }
    
}

