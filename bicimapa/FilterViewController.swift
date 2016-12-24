//
//  FilterViewController.swift
//  bicimapa
//
//  Created by Yoann Lecuyer on 28/09/15.
//  Copyright © 2015 Bicimapa. All rights reserved.
//


import Eureka
import UIKit
import CocoaLumberjack
import SwiftyJSON
import Filer

class FilterViewController : FormViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        let sitesSection = Section("Sites")
        
        for (_,category) in GlobalVariables.sharedInstance.categories {
            
            sitesSection <<< SwitchRow() {
                $0.title = category.name!
                $0.value = GlobalVariables.sharedInstance.filters[category.id]
            }.onChange { row in
                GlobalVariables.sharedInstance.filters[category.id] = row.value
                GlobalVariables.sharedInstance.needRefreshMap = true
            }
        }
        
        form +++ sitesSection
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}