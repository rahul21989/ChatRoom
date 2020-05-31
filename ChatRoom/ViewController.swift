//
//  ViewController.swift
//  ChatRoom
//
//  Created by Rahul Goyal on 31/05/20.
//  Copyright © 2020 Rahul Goyal. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    var rootView : LoginView?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = Bundle(for: LoginView.self)
        self.rootView = bundle.loadNibNamed("LoginView", owner: self, options: nil)?.first as? LoginView
        rootView!.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        view.addSubview(rootView!)
        self.rootView?.bind(self)
    }
    
    
    func login(withEmail email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil{
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
            if let user = Auth.auth().currentUser {
                let vc = GroupsViewController(currentUser: user)
                let nav = UINavigationController.init(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false, completion: nil)}
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}




