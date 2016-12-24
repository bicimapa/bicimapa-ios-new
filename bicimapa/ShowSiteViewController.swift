//
//  File.swift
//  bicimapa
//
//  Created by Yoann Lecuyer on 03/10/15.
//  Copyright © 2015 Bicimapa. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Alamofire
import SwiftyJSON
import GoogleMaps
import HCSStarRatingView
import SDCAlertView

class ShowSiteViewController: UIViewController {
    
    var siteId : Int? = nil
    
    @IBOutlet  var mapView: GMSMapView!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var ratingView: HCSStarRatingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DDLogInfo("Show site with id= \(self.siteId)")
        
        mapView.myLocationEnabled = true
        
        print("\(Constants.Bicimapa.APIRootURL)/sites/\(self.siteId!).json")
        
        Alamofire.request(.GET, "\(Constants.Bicimapa.APIRootURL)/sites/\(self.siteId!).json")
            .responseJSON { _, _, result in
                
                let json = JSON(result.value!)
                
                let comments_count = json["site"]["comments_count"].int!
                let name = json["site"]["name"].string
                let description = json["site"]["description"].string
                let latitude = json["site"]["latitude"].double!
                let longitude = json["site"]["longitude"].double!
                let category_id = json["site"]["category_id"].int!
                let added_by = json["site"]["added_by"].string!
                let nb_rating = json["site"]["nb_rating"].int!
                
                if (nb_rating > 0) {
                    let rating = json["site"]["rating"].float!
                    self.ratingView.value = CGFloat(rating)
                }
                else {
                    self.ratingView.value = 4
                    self.ratingView.alpha = 0.3
                }
                
                self.tabBarController?.title = name
                self.textView.text = description
                self.labelView.text = "Added by \(added_by)"
                
                self.mapView.camera = GMSCameraPosition.cameraWithLatitude(latitude, longitude:longitude, zoom: 17)
                
                let position = CLLocationCoordinate2DMake(latitude, longitude)
                let marker = GMSMarker(position: position)
                marker.title = name
                marker.icon = GlobalVariables.sharedInstance.categories[category_id]!.icon
                marker.map = self.mapView
                
                DDLogInfo("\(GlobalVariables.sharedInstance.categories)")
                DDLogInfo("Category id= \(category_id) name \(GlobalVariables.sharedInstance.categories[category_id]!.name)")

                
                if (comments_count > 0) {
                    self.tabBarController?.viewControllers![1].tabBarItem.badgeValue = "\(comments_count)"
                }
            }
    }
    
    @IBAction func rate(sender: UITapGestureRecognizer) {
        
        let alert = AlertController(title: "Rate", message: "Please rate this site")
        
        alert.addAction(AlertAction(title: "Cancel", style: .Default))
        alert.addAction(AlertAction(title: "Rate", style: .Preferred))
        
        alert.present()
    
    }
    
}
