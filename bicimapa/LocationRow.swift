//
//  LocationRow.swift
//  bicimapa
//
//  Created by Yoann Lecuyer on 16/01/16.
//  Copyright © 2016 Bicimapa. All rights reserved.
//

import UIKit
import Eureka
import GoogleMaps
import INTULocationManager
import CocoaLumberjack

public final class LocationRow : SelectorRow<CLLocationCoordinate2D, MapViewController, PushSelectorCell<CLLocationCoordinate2D>>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .Show(controllerProvider: ControllerProvider.Callback {return MapViewController()}, completionCallback: {
            vc in
            vc.navigationController?.popViewControllerAnimated(true)
        })
        displayValueFor = {
            guard let location = $0 else { return "" }
            let fmt = NSNumberFormatter()
            fmt.maximumFractionDigits = 4
            fmt.minimumFractionDigits = 4
            let latitude = fmt.stringFromNumber(location.latitude)!
            let longitude = fmt.stringFromNumber(location.longitude)!
            return  "\(latitude), \(longitude)"
        }
    }
}

public final class MapViewController : UIViewController, TypedRowControllerType, GMSMapViewDelegate {
    public var onPresentCallback : ((FormViewController, MapViewController)->())?
    public var presentationMode: PresentationMode<MapViewController>?
    public var row : RowOf<CLLocationCoordinate2D>!
    public var completionCallback : ((UIViewController) -> ())?

    let marker = GMSMarker.init()
    let mapView = GMSMapView.init(frame: CGRectZero)
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "tappedDone:")
        button.title = "Done"
        navigationItem.rightBarButtonItem = button
        
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        self.view = mapView
        
        marker.draggable = true
        marker.map = mapView
        
        if let value = row.value {
            marker.position = value
            let cameraUpdate = GMSCameraUpdate.setTarget(value, zoom: 16)
            mapView.moveCamera(cameraUpdate)
            updateTitle()

        }
        else{
            let locationManager = INTULocationManager.sharedInstance()
            locationManager.requestLocationWithDesiredAccuracy(INTULocationAccuracy.Block, timeout: 10) {
                (currentLocation:CLLocation!, achievedAccuracy:INTULocationAccuracy, status:INTULocationStatus) in
                
                if status == INTULocationStatus.Success {
                    DDLogVerbose("INTULocationManager Location found \(currentLocation.coordinate)")
                   
                    self.marker.position = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
                    self.mapView.camera = GMSCameraPosition.cameraWithLatitude(currentLocation.coordinate.latitude, longitude:currentLocation.coordinate.longitude, zoom: 16)
                    self.updateTitle()

                } else if status == INTULocationStatus.TimedOut {
                    DDLogWarn("INTULocationManager Timedout")
                } else{
                    DDLogError("INTULocationManager Failed")
                }
            }

        }
    }
    
    func tappedDone(sender: UIBarButtonItem){
        DDLogVerbose("Done tapped")
        row.value = marker.position
        completionCallback?(self)
    }
    
    func updateTitle(){
        let fmt = NSNumberFormatter()
        fmt.maximumFractionDigits = 4
        fmt.minimumFractionDigits = 4
        let latitude = fmt.stringFromNumber(marker.position.latitude)!
        let longitude = fmt.stringFromNumber(marker.position.longitude)!
        title = "\(latitude), \(longitude)"
    }
    
    public func mapView(mapView: GMSMapView!, didEndDraggingMarker marker: GMSMarker!) {
        updateTitle()
    }
}