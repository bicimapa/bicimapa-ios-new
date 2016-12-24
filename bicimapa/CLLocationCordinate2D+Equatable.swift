//
//  CLLocationCordinate2D+Equatable.swift
//  bicimapa
//
//  Created by Yoann Lecuyer on 16/01/16.
//  Copyright © 2016 Bicimapa. All rights reserved.
//

import GoogleMaps

extension CLLocationCoordinate2D: Equatable {}

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}