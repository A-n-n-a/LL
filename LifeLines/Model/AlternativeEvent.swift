//
//  AlternativeEvent.swift
//  LifeLines
//
//  Created by Anna on 11/1/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation
import RealmSwift

final class AlternativeEvent: Object, Decodable {
    @objc dynamic var sourceName: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var id: String = ""
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        sourceName = try container.decode(String.self, forKey: .sourceName)
        title = try container.decode(String.self, forKey: .title)
        url = try container.decode(String.self, forKey: .url)
        id = try container.decode(String.self, forKey: .categorizerId)
    }
    
    enum CodingKeys: String, CodingKey {
        case categorizerId
        case sourceName
        case title
        case url
        
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
