//
//  AddSiteViewController.swift
//  bicimapa
//
//  Created by Yoann Lecuyer on 01/10/15.
//  Copyright © 2015 Bicimapa. All rights reserved.
//

import UIKit
import GoogleMaps
import INTULocationManager
import CocoaLumberjack
import Eureka

class PositionPickerViewController : UIViewController {

    var row: RowOf<CLLocation>!
    var completionCallback : ((UIViewController) -> ())?
    
    var marker = GMSMarker()
    
    @IBOutlet weak var mapView: GMSMapView!
    override func viewDidLoad() {
        initMap()
    }
    
    func initMap() {
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        marker.map = mapView
        marker.draggable = true
        
        let locationManager = INTULocationManager.sharedInstance()
        locationManager.requestLocationWithDesiredAccuracy(INTULocationAccuracy.Block, timeout: 10) {
            (currentLocation:CLLocation!, achievedAccuracy:INTULocationAccuracy, status:INTULocationStatus) in
            
            if status == INTULocationStatus.Success {
                DDLogVerbose("INTULocationManager Location found \(currentLocation.coordinate)")
                
                self.marker.position = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
                self.mapView.camera = GMSCameraPosition.cameraWithLatitude(currentLocation.coordinate.latitude, longitude:currentLocation.coordinate.longitude, zoom: 17)
                
            } else if status == INTULocationStatus.TimedOut {
                DDLogWarn("INTULocationManager Timedout")
            } else{
                DDLogError("INTULocationManager Failed")
            }
        }
        
    }
}