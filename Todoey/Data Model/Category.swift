//
//  Category.swift
//  Todoey
//
//  Created by Michael Chen on 12/31/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

//each category has a one to many relationship with items
//by sub classing Object class we can save class into realm
class Category: Object {
    //Dynamic allow realm to monitor and change value of property, need keyword @objec
    @objc dynamic var name: String = ""
    
    //color for background
    @objc dynamic var Color: String = ""
    
    //relationship between category and list, List is a container type from realm 
    let items = List<Item>()
}
