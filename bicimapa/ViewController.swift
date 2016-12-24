//
//  ViewController.swift
//  bicimapa
//
//  Created by Yoann Lecuyer on 19/09/15.
//  Copyright © 2015 Bicimapa. All rights reserved.
//

import UIKit
import INTULocationManager
import GoogleMaps
import Filer
import CocoaLumberjack
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, GMSMapViewDelegate {
    
    var markers = [Int:GMSMarker]()
    var siteId : Int? = nil

    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBAction func addButtonClicked(sender: AnyObject) {
    
        let optionMenu = UIAlertController(title: nil, message: "Which type?", preferredStyle: .ActionSheet)
        
        
        let siteAction = UIAlertAction(title: "Site", style: .Default) {
            (alert: UIAlertAction!) -> Void in
            DDLogVerbose("Site")
            
            self.performSegueWithIdentifier("AddSiteSegue", sender: self)
            
        }
        
        let reportAction = UIAlertAction(title: "Report", style: .Default) {
            (alert: UIAlertAction!) -> Void in
            DDLogVerbose("Report")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {_ in })
        
        optionMenu.addAction(siteAction)
        optionMenu.addAction(reportAction)
        optionMenu.addAction(cancelAction)
        
        
        optionMenu.popoverPresentationController?.barButtonItem = addButton
       
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition cameraPosition: GMSCameraPosition!) {
        updateMap()
    }
    
    func updateMap() {
        
        let bounds = GMSCoordinateBounds.init(region: mapView.projection.visibleRegion())
        
        DDLogVerbose("Updating map with bounds ne=\(bounds.northEast) sw=\(bounds.southWest)")
        
        let ne = "\(bounds.northEast.latitude),\(bounds.northEast.longitude)"
        let sw = "\(bounds.southWest.latitude),\(bounds.southWest.longitude)"
        let categories = GlobalVariables.sharedInstance.filters.filter({ $0.1 == true}).map({ "\($0.0)" }).joinWithSeparator(",");
        
        DDLogInfo("categories \(categories)")
        
        Alamofire.request(.GET, "\(Constants.Bicimapa.APIRootURL)/sites/count", parameters: ["ne":ne,"sw":sw, "categories":categories])
            .responseJSON { _, _, result in
                
                let json = JSON(result.value!)
                
                let count = json["count"].int!
                
                DDLogVerbose("Count: \(count)")
                
                if (count <= 500) {
                    
                    Alamofire.request(.GET, "\(Constants.Bicimapa.APIRootURL)/sites/get", parameters: ["ne":ne,"sw":sw, "categories":categories])
                        .responseJSON { _, _, result in
                            
                            let json = JSON(result.value!)
                    
                            
                            let sites = json["sites"]
                            
                            for (_,site):(String, JSON) in sites {
                                
                                let id = site["id"].int!
                                let latitude = site["latitude"].double!
                                let longitude = site["longitude"].double!
                                let name = site["name"].string!
                                let category_id = site["category_id"].int!
                                
                                let mark = self.markers[id]
                                DDLogVerbose("mark: \(mark)")
                                
                                if (mark == nil) {
                                
                                    let position = CLLocationCoordinate2DMake(latitude, longitude)
                                    let marker = GMSMarker(position: position)
                                    marker.title = name
                                    marker.icon = GlobalVariables.sharedInstance.categories[category_id]!.icon
                                    marker.map = self.mapView
                                
                                    self.markers[id] = marker
                                    
                                }
                            }
                            
                            
                            if (self.markers.count >= Constants.maxMarkersCountOnMap) {
                                self.garbageCollectMarkers();
                            }
                            
                            DDLogInfo("Currently displaying \(self.markers.count)")

                    }
                }
                else {
                    DDLogInfo("Too much data. Rendering nothing")
                }
        }
    
    }
    
    func garbageCollectMarkers() {
        
        DDLogInfo("Garbage collect markers")
        DDLogVerbose("Before: \(self.markers.count)")
        
        let bounds = GMSCoordinateBounds.init(region: mapView.projection.visibleRegion())
        
        let keysToRemove = markers.keys.filter { bounds.containsCoordinate(self.markers[$0]!.position) == false }
        
        for key in keysToRemove {
            let marker = markers[key]!
            marker.map = nil
            markers.removeValueForKey(key)
        }
        
       
        DDLogVerbose("After: \(self.markers.count)")

    }
    
    func clearAllMarker() {
        
        DDLogInfo("Clearing all markers")
        DDLogVerbose("Before: \(self.markers.count)")
        
        
        for (_, marker) in markers {
            marker.map = nil
        }
        
        markers = [Int:GMSMarker]()
        
        DDLogVerbose("After: \(self.markers.count)")
        
    }
    
    func initMap() {
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        mapView.delegate = self
        
        let locationManager = INTULocationManager.sharedInstance()
        locationManager.requestLocationWithDesiredAccuracy(INTULocationAccuracy.Block, timeout: 10) {
            (currentLocation:CLLocation!, achievedAccuracy:INTULocationAccuracy, status:INTULocationStatus) in
            
            if status == INTULocationStatus.Success {
                DDLogVerbose("INTULocationManager Location found \(currentLocation.coordinate)")
            
                self.mapView.camera = GMSCameraPosition.cameraWithLatitude(currentLocation.coordinate.latitude, longitude:currentLocation.coordinate.longitude, zoom: 16)
    
            } else if status == INTULocationStatus.TimedOut {
                DDLogWarn("INTULocationManager Timedout")
            } else{
                DDLogError("INTULocationManager Failed")
            }
        }
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        
        siteId = (markers as NSDictionary).allKeysForObject(marker).first as! Int?
        
        
        DDLogInfo("Marker id= \(self.siteId)")
        
        self.performSegueWithIdentifier("ShowSiteSegue", sender: self)
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        initMap()
    }
    
    override func viewDidAppear(animated: Bool) {
        DDLogVerbose("View did appear")
        
        if (GlobalVariables.sharedInstance.needRefreshMap) {
            clearAllMarker()
            updateMap()
            GlobalVariables.sharedInstance.needRefreshMap = false;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "ShowSiteSegue") {
            let tabBarController = segue.destinationViewController as! UITabBarController
            
            let showController = tabBarController.viewControllers![0] as! ShowSiteViewController
            showController.siteId = self.siteId
            
            let commentsController = tabBarController.viewControllers![1] as! SiteCommentsViewController
            commentsController.siteId = self.siteId
            
            let picturesController = tabBarController.viewControllers![2] as! SitePicturesViewController
            picturesController.siteId = self.siteId
        }
        
    }

}

