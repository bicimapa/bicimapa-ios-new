//
//  Category.swift
//  bicimapa
//
//  Created by Yoann Lecuyer on 30/09/15.
//  Copyright © 2015 Bicimapa. All rights reserved.
//

import UIKit
import SwiftyJSON
import Filer
import CocoaLumberjack

class Category : Equatable, CustomStringConvertible {
    
    var id : Int!
    var icon : UIImage!
    var name : String!
    var is_public : Bool!
    var variety : String!
    var is_active : Bool!
    var iconPath : String!
    
    var filename : String! {
        get {
            return name + ".png"
        }
    }
    
    var description : String {
        return name
    }
    
    init() {
        
    }
    
    init(json: JSON) {
        
        self.id = json["id"].int!
        self.variety = json["variety"].string
        self.name = json["name"].string
        self.iconPath = json["icon_path"].string
        self.is_active = json["is_active"].bool!
        self.is_public = json["is_public"].bool!

    }
    
    init(mapping: JSON) {
        self.id = mapping["id"].int!
        self.is_public = mapping["is_public"].bool!
        self.name = mapping["name"].string!
        self.is_active = mapping["is_active"].bool!
        self.variety = mapping["variety"].string!
    }
    
    static func loadCategories() -> [Int:Category] {
        
        var categories = [Int:Category]()
        
        DDLogInfo("Loading categories as NSDictionary")
            
        let mapping = JSON(data: File(directory: .Document, path: "\(Constants.iconsFolder)/mappings.json").readData()!)
            
        DDLogVerbose(mapping.rawString()!)
            
        for (_, categoryMapping):(String, JSON) in mapping {
            
            let category = Category(mapping: categoryMapping)
            
            let filePath = Constants.iconsFolder + "/" + category.filename
            
            DDLogVerbose("category_id: \(category.id) \(filePath)")
            
            category.icon = File(directory: .Document, path: filePath).readImage()
            
            categories[category.id] = category;
        }
            
        DDLogInfo("\(categories.count) icons loaded")
        
        return categories
    }
    
    static func loadFilters() -> [Int:Bool] {
        
        var filters = [Int:Bool]()
        
        DDLogInfo("Loading filters as NSDictionary")
        
        let mapping = JSON(data: File(directory: .Document, path: "\(Constants.iconsFolder)/mappings.json").readData()!)
        
        DDLogVerbose(mapping.rawString()!)
        
        for (_, categoryMapping):(String, JSON) in mapping {
            
            filters[categoryMapping["id"].int!] = true;
        }
        
        return filters
        
    }
    
    /*static func loadCategories() -> [Category] {
        let categories : [Int:Category] = loadCategories()
        return Array(categories.values)
    }*/
    
    func toMapping() -> NSDictionary {
        let mapping = [
            "id": self.id,
            "name": self.name,
            "is_public": self.is_public,
            "is_active": self.is_active,
            "variety": self.variety
        ]
        
        return mapping
    }
}


func ==(lhs: Category, rhs: Category) -> Bool {
    return lhs.id == rhs.id
}