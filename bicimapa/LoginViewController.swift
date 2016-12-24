//
//  LoginViewController.swift
//  bicimapa
//
//  Created by Yoann Lecuyer on 15/01/16.
//  Copyright © 2016 Bicimapa. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import CocoaLumberjack
import Alamofire
import SwiftyJSON

class LoginViewController : UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            DDLogDebug("User already connected")
            
            processFacebookLogin()
        }
    }

    
    @IBAction func login(sender: AnyObject) {
        Alamofire.request(Method.GET, Constants.Bicimapa.APIRootURL + "/session/get_user_token_from_devise", parameters: ["email": login.text!, "password": password.text!])
            .responseJSON { _, _, result in
                
                let json = JSON(result.value!)
                
                let token = json["token"].string!
                
                DDLogInfo("User token: \(token)")
                self.saveToken(token)
        }

    }
    
    @IBAction func skip(sender: AnyObject) {
        DDLogVerbose("Skipped login")
        saveToken("")
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        //TODO Check account creation
        //TODO Check email permission validation
        
        DDLogDebug("User Logged In")
        processFacebookLogin()
    }
    
    func processFacebookLogin() {
        
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id"]).startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                DDLogError("Error: \(error)")
            }
            else
            {
                let facebook_id = result.valueForKey("id") as! String
                DDLogVerbose("Facebook id = \(facebook_id)")
                
                Alamofire.request(Method.GET, Constants.Bicimapa.APIRootURL + "/session/get_user_token_from_facebook_id", parameters: ["facebook_id": facebook_id])
                    .responseJSON { _, _, result in
                    
                    let json = JSON(result.value!)
                        
                    let token = json["token"].string!
                        
                    DDLogInfo("User token: \(token)")
                    self.saveToken(token)
                }
            }
        })

    }
    
    func saveToken(token: String) {
        GlobalVariables.sharedInstance.token = token;
        performSegueWithIdentifier("GoToLoading", sender: nil)
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        DDLogDebug("User logged out")
    }
    
}
