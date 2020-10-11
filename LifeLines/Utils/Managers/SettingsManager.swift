//
//  SettingsManager.swift
//  LifeLines
//
//  Created by Anna on 7/18/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation
import RealmSwift

class SettingsManager {
    
    class var categories: Results<Category>? {
        return RealmManager.getObjects(type: Category.self, withFilter: nil)
    }
    
    class var selectedCategories: Results<Category>? {
        return RealmManager.getObjects(type: Category.self, withFilter: "isEnable == true")
    }
    
    class var selectedCategoriesTitles: [String]? {
        if let categories = SettingsManager.selectedCategories {
            return categories.map({ (category) -> String in
                return category.title
            })
        }
        return nil
    }
    
    static var cities = [String]()
    
    
    static var allCategoriesSelected: Bool {
        let unselected = RealmManager.getObjects(type: Category.self, withFilter: "isEnable == false")
        return unselected?.count == 0
    }
    
    static var locationSettings = SettingsLocations()
    
    static var lastCity: String? {
        get {
            return UserDefaults.standard.string(forKey: "LastCity")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "LastCity")
        }
    }
}
