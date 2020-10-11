//
//  KeyCodingContayner + Utils.swift
//  LifeLines
//
//  Created by Anna on 7/7/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation
import RealmSwift

extension KeyedDecodingContainer {
    
    func map(_ variable: List<String>, _ key: KeyedDecodingContainer.Key) throws -> List<String> {
        let res = List<String>.init()
        if let someString = try? self.decode(String.self, forKey: key) {
            res.append(someString)
        } else if let result = try? self.decode([String].self, forKey: key) {
            res.append(objectsIn: result)
        }
        
        return res
    }
}
