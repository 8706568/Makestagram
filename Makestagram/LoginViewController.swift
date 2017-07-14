//
//  LoginViewController.swift
//  Makestagram
//
//  Created by camille_mille on 2017/7/11.
//  Copyright © 2017年 Make School. All rights reserved.
//
import UIKit
import FirebaseAuth
import FirebaseAuthUI
import FirebaseDatabase

class LoginViewController: UIViewController{
    typealias FIRUser = FirebaseAuth.User

    @IBOutlet weak var LoginButton: UIButton!
    
 

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
   
    
    @IBAction func LoginButtonTapped(_ sender: UIButton) {
        // 1
        guard let authUI = FUIAuth.defaultAuthUI()
            else { return }
        
        // 2
        authUI.delegate = self
        
        // 3
        let authViewController = authUI.authViewController()
        present(authViewController, animated: true)
    
    }
}

    extension LoginViewController: FUIAuthDelegate {
        func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
            func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
                // ...
                
                UserService.show(forUID: (user?.uid)!) { (user) in
                    if let user = user {
                        // handle existing user
                        User.setCurrent(user, writeToUserDefaults: true)
                        
                        let initialViewController = UIStoryboard.initialViewController(for: .main)
                        self.view.window?.rootViewController = initialViewController
                        self.view.window?.makeKeyAndVisible()
                    } else {
                        // handle new user
                        self.performSegue(withIdentifier: Constants.Segue.toCreateUsername, sender: self)
                    }
                }}
            // 1
            guard let user = user
                else { return }
            
            // 2
            let userRef = Database.database().reference().child("users").child(user.uid)
            
            // 3
            userRef.observeSingleEvent(of: .value, with: { [unowned self] (snapshot) in
                if let user = User(snapshot: snapshot) {
                    print("Welcome back, \(user.username).")
                } else {
                    self.performSegue(withIdentifier: "toCreateUsername", sender: self)
                }
            })
            
            
            userRef.observeSingleEvent(of: .value, with: { [unowned self] (snapshot) in
                if let user = User(snapshot: snapshot) {
                    User.setCurrent(user)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: .main)
                    if let initialViewController = storyboard.instantiateInitialViewController() {
                        self.view.window?.rootViewController = initialViewController
                    }
                } else {
                    // 1
                    self.performSegue(withIdentifier: Constants.Segue.toCreateUsername, sender: self)
                }
            })
        }
}
