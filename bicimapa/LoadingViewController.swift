//
//  LoadingViewController.swift
//  bicimapa
//
//  Created by Yoann Lecuyer on 19/09/15.
//  Copyright © 2015 Bicimapa. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Filer
import SwiftyUserDefaults
import CocoaLumberjack


class LoadingViewController : UIViewController {
    
    let group = dispatch_group_create()
    
    var mappings = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if isUpdateNeeded() {
            update()
        }
        else {
            goToMainController()
        }
        
    }
    
    func goToMainController() {
        DDLogVerbose("Launching MainControllerView")
        self.performSegueWithIdentifier("GoToMain", sender: nil)
    }
    
    func isUpdateNeeded() -> Bool {
        
        DDLogInfo("Last update on \(Defaults[Constants.UserDefaults.lastUpdate])")
        
        return true
    }
  
    func initFileSystem() {
        Filer.mkdir(.Document, dirName: Constants.iconsFolder)
    }
    
    func saveCategory(category:Category) {
        DDLogVerbose("Saving Category id=\(category.id) located at iconPath=\(category.iconPath)")
        
        dispatch_group_enter(group)
    
        let url = Constants.Bicimapa.rootURL + category.iconPath
        
        Alamofire.request(Method.GET, url).response {
            (_ ,_ , data, _) in
            
            DDLogVerbose("Saving file \(category.name)")
            
            let fileName = "\(category.name).png"
            
            let mapping = category.toMapping()
            
            self.mappings.append(mapping)
            
            File(directory: .Document, fileName: "\(Constants.iconsFolder)/\(fileName)").writeData(data!)
            
            dispatch_group_leave(self.group)
        }
        
    }
    
    func saveCategoryMapping() {
        
        do {
            let json = try JSON(mappings).rawData()
            File(directory: .Document, fileName: "\(Constants.iconsFolder)/mappings.json").writeData(json)
            DDLogInfo("Mapping saved")
        }
        catch let error as NSError {
            DDLogError(error.localizedDescription)
        }
    }
    
    func update() {
        
        DDLogInfo("Updating")
        
        initFileSystem()
        
        
        Alamofire.request(.GET, "\(Constants.Bicimapa.APIRootURL)/categories.json")
            .responseJSON { _, _, result in

                let json = JSON(result.value!)
                
                let categories = json["categories"]
                
                for (_, categoryJSON):(String, JSON) in categories {
                    
                    let category = Category(json: categoryJSON)
                    
                    if (category.variety == "SIT" && category.is_active == true) {
                        DDLogVerbose("Saving \(category.name)")
                        self.saveCategory(category)
                    }
                    
                }
                
                dispatch_group_notify(self.group, dispatch_get_main_queue()) {
                    
                    self.saveCategoryMapping()
                    Defaults[Constants.UserDefaults.lastUpdate] = NSDate()
                    
                    DDLogInfo("Updated")
                    
                    self.goToMainController()
                }
                
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}