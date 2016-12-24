//
//  GlobalVariables.swift
//  bicimapa
//
//  Created by Yoann Lecuyer on 06/01/16.
//  Copyright © 2016 Bicimapa. All rights reserved.
//

class GlobalVariables {
    static let sharedInstance = GlobalVariables()
    
    var categories : [Int:Category] = Category.loadCategories()
    var filters : [Int:Bool] = Category.loadFilters();
    var needRefreshMap = false;
    var token : String = "";

}