//
//  SignInVC.swift
//  PocketSong
//
//  Created by Seunghyeon Kang on 10/11/21.
//

import Foundation
import UIKit
import FirebaseCore
import GoogleSignIn
import FirebaseAuth

public class SignInVC :UIViewController {

    @IBOutlet weak var btnGoogleLogin: UIButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        print("[SignInVC] viewDidLoad")
        
        self.view.backgroundColor = UIColor(hex: 0x009051)
    }
    
    override public func viewDidLayoutSubviews() {
        self.btnGoogleLogin.tintColor = UIColor(hex: 0x18324C)
    }
    
    
    @IBAction func checkGoogleLogin(){
        self.btnGoogleLogin.isHidden = true
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.btnGoogleLogin.isHidden = false
            return
        }

        let config = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            if let error = error{
                self.alertDefault(title: "Login Failed", message: error.localizedDescription) {
                    self.btnGoogleLogin.isHidden = false
                    return
                }
            }

            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                self.btnGoogleLogin.isHidden = false
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential){ (authResult, error) in
                if let error = error {
                    self.alertDefault(title: "Auth Failed", message: error.localizedDescription){
                        self.btnGoogleLogin.isHidden = false
                        return
                    }
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "MainTabBarVC")
                vc.modalPresentationStyle = .fullScreen
                
                self.present(vc, animated: false)
            }
            
        }
        
    }
}
