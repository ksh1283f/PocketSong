//
//  TestVC.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 8/19/22.
//

import UIKit
import Foundation

class TestVC: UIViewController {
    
    @IBOutlet weak var testStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStackViewWithTestData()
    }
    
    func setupStackViewWithTestData(){
        for test in 0..<20{
            let view = UIView()
            view.backgroundColor = UIColor(displayP3Red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1)
            view.isUserInteractionEnabled = true
            view.heightAnchor.constraint(equalToConstant: .random(in: 100...300)).isActive = true
            testStackView.addArrangedSubview(view)
            
            
        }
    }
}
