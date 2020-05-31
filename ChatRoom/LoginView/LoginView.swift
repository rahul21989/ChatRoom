//
//  LoginView.swift
//  ChatRoom
//
//  Created by Rahul Goyal on 31/05/20.
//  Copyright © 2020 Rahul Goyal. All rights reserved.
//

import UIKit

class LoginView: UIView {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    weak var currentController:ViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func loginAction(_ sender: Any) {
        AppSettings.displayName = userName.text!
        currentController?.login(withEmail: email.text!, password: password.text!)
    }
            
    func bind(_ controller: UIViewController) {
        currentController = controller as? ViewController
    }
}
