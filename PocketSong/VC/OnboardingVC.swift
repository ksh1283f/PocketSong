//
//  OnboardingVC.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 8/24/22.
//

import UIKit
import Lottie
import FirebaseAuth

class OnboardingVC: UIViewController {
    
    @IBOutlet weak var onboardingPageControl: UIPageControl!
    @IBOutlet weak var btnNext: UIButton!
    var id:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        id = String(self.hashValue)
        
        
        ObserverMediator.shared.addObserverMediate(self)
        print("[OnboardingPagevc] add observerMediate")
        onboardingPageControl.pageIndicatorTintColor = .gray
        onboardingPageControl.currentPageIndicatorTintColor = .white
        btnNext.setTitle(LocalizeText.Next, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        btnNext.layer.masksToBounds = false
        btnNext.layer.cornerRadius = 15;
        
        btnNext.layer.shadowColor = UIColor.black.cgColor
        btnNext.layer.shadowOpacity = 0.5
        btnNext.layer.shadowOffset = CGSize(width: 3, height: 3)
        btnNext.layer.shadowRadius = 5
        
        btnNext.layer.isHidden = true
        btnNext.isUserInteractionEnabled = false
    }
    
    @IBAction func OnPageControlChanged(_ pageControl: UIPageControl) {
        let currentPageIndex = pageControl.currentPage
        customPageViewController.goToPage(index: currentPageIndex)
    }
    
    @IBAction func onClickedBtnNext(_ sender: Any) {
        
        var targetStoryboardName = ""
        var targetToInstantiateVCId = ""
        if Auth.auth().currentUser != nil {
            targetStoryboardName = "Main"
            targetToInstantiateVCId = "MainTabBarVC"
        }else{
            targetStoryboardName = "LoginPage"
            targetToInstantiateVCId = "SignInVC"
        }
        
        
        let storyboard = UIStoryboard(name: targetStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: targetToInstantiateVCId)
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
