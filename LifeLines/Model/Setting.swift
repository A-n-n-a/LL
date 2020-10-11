//
//  Setting.swift
//  LifeLines
//
//  Created by Anna on 7/18/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation
import RealmSwift

final class Category: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var isEnable: Bool = false

    required convenience init(title: String, isEnable: Bool = false) {
        self.init()
        self.title = title
        self.isEnable = isEnable
    }

    override static func primaryKey() -> String? {
        return "title"
    }
}
