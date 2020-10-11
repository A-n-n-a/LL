//
//  TagsHistory.swift
//  LifeLines
//
//  Created by Anna on 8/19/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation
import RealmSwift

final class TagsHistory: Object {
    @objc dynamic var tag: String = ""
    
    required convenience init(tag: String) {
        self.init()
        
        self.tag = tag
    }
    
    override static func primaryKey() -> String? {
        return "tag"
    }
}
