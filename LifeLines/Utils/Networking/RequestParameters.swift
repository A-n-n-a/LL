//
//  RequestParameters.swift
//  TapTaxi-New
//
//  Created by Anna on 4/23/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation
import CoreLocation

struct GetAllEventsParameters: ParametersProtocol {
    var keywords: String?
    var category: String?
    var place: String?
    var hashtag: String?
    var hashtags: [String]?
    var page: Int?
    var query: String?

    var dictionaryValue: Parameters {
        var data = [String : Any]()
        if let keywords = keywords {
            data["keywords"] = keywords
        }
        if let category = category {
            data["categories"] = category
        }
        if let hashtag = hashtag {
            data["hashtag"] = hashtag
        }
        if let place = place {
            data["place"] = place
        }
        if let hashtags = hashtags {
            data["hashtag"] = hashtags
        }
        if let page = page {
            data["page"] = page
        }
        if let query = query {
            data["query"] = query
        }

        return data
    }
}

struct EventIdParameters: ParametersProtocol {
    var eventId: String
    
    var dictionaryValue: Parameters {
        let data:[String : Any] = ["id": eventId]
        
        return data
    }
}

struct EmptyParameters: ParametersProtocol {
    var dictionaryValue: Parameters {
        return [String : Any]()
    }
}

struct SaveCategoryParameters: ParametersProtocol {
    var name: String
    var value: Bool
    
    var dictionaryValue: Parameters {
        let data:[String : Any] = ["name": name,
                                   "value": value]
        
        return data
    }
}

struct SaveLocationParameters: ParametersProtocol {
    var name: String
    var value: Any
    
    var dictionaryValue: Parameters {
        let data:[String : Any] = ["name": name,
                                   "value": value]
        
        return data
    }
}

class SetLocationParameters: ParametersProtocol {
    var world: Bool
    var federal: Bool
    var local: String?
    
    init(world: Bool, federal: Bool, local: String?) {
        self.world = world
        self.federal = federal
        self.local = local
    }
    
    var locations = [String]()
    var dictionaryValue: Parameters {
        
        if world {
            locations.append("Мировые")
        }
        if federal {
            locations.append("Федеральные")
        }
        if let local = local {
            locations.append(local)
        }
        
        let data:[String : Any] = ["locations" : Array(Set(locations))]
        
        return data
    }
}

struct SaveLocalLocationParameters: ParametersProtocol {
    var city: String?
    
    var dictionaryValue: Parameters {
        var data:[String : Any] = ["name": "LOCAL"]
        if let city = city {
            data["value"] = city
        } else {
            data["value"] = nil
        }
        
        return data
    }
}

