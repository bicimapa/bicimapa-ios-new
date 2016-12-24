//
//  Constants.swift
//  bicimapa
//
//  Created by Yoann Lecuyer on 20/09/15.
//  Copyright © 2015 Bicimapa. All rights reserved.
//

import SwiftyUserDefaults

struct Constants {
    struct UserDefaults {
        static let lastUpdate = DefaultsKey<NSDate?>("lastUpdate")
    }
    static let iconsFolder = "icons"
    struct Bicimapa {
        //static let rootURL = "http://bicimapa.com"
        static let rootURL = "http://localhost:3000"
        static let APIRootURL = Constants.Bicimapa.rootURL + "/api/v1"
    }
    static let maxMarkersCountOnMap = 600
}