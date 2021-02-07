//
//  Item.swift
//  Todoey
//
//  Created by Michael Chen on 12/30/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object{
    //Dynamic allow realm to monitor and change value of property, need keyword @objec
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    /*each item have inverse relation to catergory, property is name of forward relationship "items"
     in category class
     LinkingObjects ia an auto-updating container type
    */
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    
}























//Item can enode itself to external representation like plist or json as well as decoded 
//struct Item: Codable {
//    var title: String = ""
//    var done: Bool = false
//}

