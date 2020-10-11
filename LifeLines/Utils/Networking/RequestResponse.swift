//
//  RequestResponse.swift
//  TapTaxi-New
//
//  Created by Anna on 4/23/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation

struct BaseBoolResponse: Codable {
    var success: Bool?
    
    enum CodingKeys: String, CodingKey {
        case success
    }
}

struct EventsResponse: Decodable {
    var result: [Event]
    
    enum CodingKeys: String, CodingKey {
        case result = "events"
    }
}

struct SingleEventResponse: Decodable {
    var result: Event
    
    enum CodingKeys: String, CodingKey {
        case result = "event"
    }
}

struct PhenomenaResponse: Decodable {
    var result: [String]
    
    enum CodingKeys: String, CodingKey {
        case result = "events"
    }
}

struct EmptyResponse: Decodable {
    let result: String?
    
    enum CodingKeys: String, CodingKey {
        case result = "result"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        result = try? container.decode(String.self, forKey: .result)
    }
}

struct CategoriesResponse: Decodable {
    var result: [String]
    
    enum CodingKeys: String, CodingKey {
        case result = "categories"
    }
}

struct CitiesList: Decodable {
    var header: String?
    var cities: [String]
}

struct LocationsResponse: Decodable {
    var result: [CitiesList]?
    
    enum CodingKeys: String, CodingKey {
        case result = "locations"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        result = try container.decode([CitiesList].self, forKey: .result)
    }
}
//Categories
struct SettingsResponse: Decodable {
    var result: [String: Bool]
    
    enum CodingKeys: String, CodingKey {
        case result = "settings"
    }
}

struct SettingsLocationsResponse: Decodable {
    var result: SettingsLocations
    
    enum CodingKeys: String, CodingKey {
        case result = "settings"
    }
}

struct FavoritesResponse: Decodable {
    var result: [Event]?
    
    enum CodingKeys: String, CodingKey {
        case result = "favorites"
    }
}


struct ResponseError: Decodable {
    let errors: Global
}

struct Global: Decodable {
    let global: [ErrorText]
}

struct ErrorText: Decodable {
    let text: String
}
