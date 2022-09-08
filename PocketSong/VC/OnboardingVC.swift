//
//  OnboardingVC.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 8/24/22.
//

import UIKit
import Lottie

class OnboardingVC: UIViewController {
    
    @IBOutlet weak var onboardingPageControl: UIPageControl!
    @IBOutlet weak var btnNext: UIButton!
    var id:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnNext.layer.cornerRadius = 15;
        btnNext.layer.shadowColor = UIColor.gray.cgColor
        btnNext.layer.shadowOpacity = 1.0
        btnNext.layer.shadowOffset = CGSize.zero
        btnNext.layer.shadowRadius = 6
        
        id = String(self.hashValue)
        
        
        ObserverMediator.shared.addObserverMediate(self)
        print("[OnboardingPagevc] add observerMediate")
        onboardingPageControl.pageIndicatorTintColor = .gray
        onboardingPageControl.currentPageIndicatorTintColor = .white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        btnNext.layer.isHidden = true
        btnNext.isUserInteractionEnabled = false
    }
    
    @IBAction func OnPageControlChanged(_ pageControl: UIPageControl) {
        let currentPageIndex = pageControl.currentPage
        customPageViewController.goToPage(index: currentPageIndex)
    }
    
    @IBAction func onClickedBtnNext(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainTabBarVC")
        vc.modalPresentationStyle = .fullScreen
        
        
        // todo deinit observerMediator
        present(vc, animated: false)
        
        
    }
    
    var customPageViewController : OnboardPageVC!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let destVC = segue.destination as? OnboardPageVC{
            customPageViewController = destVC
            customPageViewController.customDelegate = self
        }
    }
}

extension OnboardingVC : Observer{
    
    func update(message: String) {
        btnNext.layer.isHidden = false
        btnNext.isUserInteractionEnabled = true
    }
}

extension OnboardingVC : CustomPageViewControllerDelegate{
    func numberOfPage(numberOfPage: Int) {
        onboardingPageControl.numberOfPages = numberOfPage
    }
    
    func pageChangedTo(index: Int) {
        onboardingPageControl.currentPage = index
    }
}

protocol CustomPageViewControllerDelegate : AnyObject{
    func numberOfPage(numberOfPage: Int)
    func pageChangedTo(index:Int)
}
