//
//  LoginViewController.swift
//  vyse
//
//  Created by Stratazima on 5/27/15.
//  Copyright (c) 2015 Stratazima. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    @IBAction func loginButton(sender: AnyObject) {
        if usernameText.text != "" || passwordText.text != "" {
            
        } else {
            if usernameText == "" {
                usernameText.placeholder = "Cannot be blank"
            }
            if passwordText.text == "" {
                passwordText.placeholder = "Cannot be blank"
            }
        }
    }
    
    @IBAction func forgotButton(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://foursquare.com/login?continue=%2F&clicked=true")!)
    }
}
