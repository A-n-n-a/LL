//
//  SearchResult.swift
//  LifeLines
//
//  Created by Anna on 7/22/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation
import RealmSwift

final class SearchResult: Object {
    @objc dynamic var query: String = ""
    
    required convenience init(query: String) {
        self.init()
        
        self.query = query
    }
    
    override static func primaryKey() -> String? {
        return "query"
    }
}
