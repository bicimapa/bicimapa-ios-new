//
//  SaveSiteViewController.swift
//  bicimapa
//
//  Created by Yoann Lecuyer on 02/10/15.
//  Copyright © 2015 Bicimapa. All rights reserved.
//

import Eureka
import GoogleMaps
import CocoaLumberjack
import Alamofire

class AddSiteViewController : FormViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        form +++ Section("Site")
            
        <<< TextRow("name") {
            $0.title = "Name"
        }
        
        <<< TextAreaRow("description") {
            $0.placeholder = "Description"
        }

        <<< LocationRow("location") {
            $0.title = "Location"
        }
         
        <<< AlertRow<Category>("category") {
            $0.title = "Category"
            $0.selectorTitle = "Which category?"
            $0.options = Array(GlobalVariables.sharedInstance.categories.values)
        }
            
        <<< ImageRow("picture") {
                $0.title = "Picture"
        }
    }
    
    @IBAction func save(sender: AnyObject) {
        DDLogVerbose("Save site")
     
        DDLogInfo("\(form.values())")
        
        let parameters = [
            "name": form.rowByTag("name")?.baseValue as! AnyObject,
            "description": form.rowByTag("description")?.baseValue as! AnyObject,
            "latitude": 0,
            "longitude": 0,
            "category_id": 3,
            "token" : "" //TODO: add token
        ]
        
        Alamofire.request(.POST, "\(Constants.Bicimapa.APIRootURL)/sites", parameters: parameters)
            .responseJSON { _, _, result in
                DDLogVerbose("Site created")
        }

    }
}
