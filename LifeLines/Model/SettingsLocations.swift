//
//  SettingsLocations.swift
//  LifeLines
//
//  Created by Anna on 7/27/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation

class SettingsLocations: Decodable {
    
    var world: Bool = false
    var federal: Bool = false
    var local: String? = nil
    
    init() {}
    
    init(world: Bool, federal: Bool, local: String?) {
        self.world = world
        self.federal = federal
        self.local = local
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        world = try container.decode(Bool.self, forKey: .world)
        federal = try container.decode(Bool.self, forKey: .federal)
        local = try? container.decode(String.self, forKey: .local)
    }
    
    enum CodingKeys: String, CodingKey {
        case world = "WORLD"
        case federal = "FEDERAL"
        case local = "LOCAL"
    }
    
    func copy() -> SettingsLocations {
        let copy = SettingsLocations(world: self.world, federal: self.federal, local: self.local)
        return copy
    }
}
