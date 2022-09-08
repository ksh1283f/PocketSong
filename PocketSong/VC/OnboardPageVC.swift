//
//  OnboardPageVC.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 8/25/22.
//

import UIKit

class OnboardPageVC: UIPageViewController {
    var contentsVcList:[OnboardContentsVC] = []
    var observers:[Observer] = []
    weak var customDelegate: CustomPageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        ObserverMediator.shared.setupObserverMediator(subject: self)
        
        
        // dummy test
        for i in 0..<3 {
            let result = OnboardContentsVC.getInstance(idx: i)
            contentsVcList.append(result)
        }
        
        setViewControllers([contentsVcList[0]], direction: .forward, animated: true)
        customDelegate?.numberOfPage(numberOfPage: contentsVcList.count)
        
    }
    
    func goToPage(index: Int){
        let currentViewController = viewControllers!.first!
        let currentViewControllerIndex = contentsVcList.firstIndex(of: currentViewController as! OnboardContentsVC)!
        
        let direction: NavigationDirection = index > currentViewControllerIndex ? .forward : .reverse
        setViewControllers([contentsVcList[index]], direction: direction, animated: true)
    }
}

extension OnboardPageVC : UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let indexOfVc = contentsVcList.firstIndex(of: viewController as! OnboardContentsVC)!
        if indexOfVc == 0 {
            return nil
        }else{
            return contentsVcList[indexOfVc - 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let indexOfVc = contentsVcList.firstIndex(of: viewController as! OnboardContentsVC)!
        if indexOfVc == contentsVcList.count - 1 {
            print("[OnboardingPagevc] self.notify")
            self.notify(message: "OnboardingEnd")
            return nil
        }else{
            return contentsVcList[indexOfVc + 1]
        }
    }
    
}

extension OnboardPageVC : Subject{
    func subscribe(observer: Observer) {
        observers.append(observer)
    }
    
    func unSubscribe(observer: Observer) {
        if let idx = self.observers.firstIndex(where: {$0.id == observer.id}){
            self.observers.remove(at: idx)
        }
    }
    
    func notify(message: String) {
        for observer in observers {
            observer.update(message: "message")
        }
    }
}

extension OnboardPageVC: UIPageViewControllerDelegate{
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentPageViewController = pageViewController.viewControllers?.first as? OnboardContentsVC{
            let index = contentsVcList.firstIndex(of: currentPageViewController)!
            customDelegate?.pageChangedTo(index: index)
        }
    }
}
