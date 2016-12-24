//
//  SitePicturesViewController.swift
//  bicimapa
//
//  Created by Yoann Lecuyer on 23/10/15.
//  Copyright © 2015 Bicimapa. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON

class SitePicturesViewController : UIViewController {
    
    @IBOutlet weak var streetView: GMSPanoramaView!
    
    var siteId : Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        Alamofire.request(.GET, "\(Constants.Bicimapa.APIRootURL)/sites/\(self.siteId!).json")
            .responseJSON { _, _, result in
                
                let json = JSON(result.value!)
                
                let latitude = json["site"]["latitude"].double!
                let longitude = json["site"]["longitude"].double!
                
                let position = CLLocationCoordinate2DMake(latitude, longitude)
                self.streetView.moveNearCoordinate(position)
        }
        
    }
    
}
