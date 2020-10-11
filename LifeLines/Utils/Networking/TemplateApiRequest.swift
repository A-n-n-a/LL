//
//  TemplateApiRequest.swift
//  TapTaxi-New
//
//  Created by Anna on 4/23/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation

enum TemplatesAPIRequest: RestApiMethod {
    case getAllEvents(GetAllEventsParameters)
    case getSingleEvent(EventIdParameters)
    case phenomena(EventIdParameters)
    case getFavorites(EmptyParameters)
    case addFavorite(EventIdParameters)
    case deleteFavorite(EventIdParameters)
    case categories(EmptyParameters)
    case locations(EmptyParameters)
    case settingsCategories(EmptyParameters)
    case saveSettingsCategories(SaveCategoryParameters)
    case getLocations(EmptyParameters)
    case setLocations(SetLocationParameters)
    case saveLocation(SaveLocationParameters)
    case saveLocalLocation(SaveLocalLocationParameters)
    case newPhenomenas(EventIdParameters)
    
    var data: RestApiData {
        switch self {
        case .getAllEvents(let parameters):
            return RestApiData(url: url, httpMethod: .get, parameters: parameters)
        case .getSingleEvent(let parameters):
            return RestApiData(url: url+Constants.Endpoints.singleEvent, httpMethod: .get, parameters: parameters)
        case .phenomena(let parameters):
            return RestApiData(url: url+Constants.Endpoints.phenomena, httpMethod: .get, parameters: parameters)
        case .getFavorites(let parameters):
            return RestApiData(url: url+Constants.Endpoints.favorites, httpMethod: .get, parameters: parameters)
        case .addFavorite(let parameters):
            return RestApiData(url: url+Constants.Endpoints.favorites, httpMethod: .post, parameters: parameters)
        case .deleteFavorite(let parameters):
            return RestApiData(url: url+Constants.Endpoints.favorites, httpMethod: .delete, parameters: parameters)
        case .categories(let parameters):
            return RestApiData(url: url+Constants.Endpoints.categories, httpMethod: .get, parameters: parameters)
        case .locations(let parameters):
            return RestApiData(url: url+Constants.Endpoints.locations, httpMethod: .get, parameters: parameters)
        case .settingsCategories(let parameters):
            return RestApiData(url: url+Constants.Endpoints.settingsCategories, httpMethod: .get, parameters: parameters)
        case .saveSettingsCategories(let parameters):
            return RestApiData(url: url+Constants.Endpoints.settingsCategories, httpMethod: .put, parameters: parameters)
        case .getLocations(let parameters):
            return RestApiData(url: url+Constants.Endpoints.settingsLocations, httpMethod: .get, parameters: parameters)
        case .setLocations(let parameters):
            
            var endpoint = "?"
            if parameters.world {
                endpoint.append("locations=Мировые")
            }
            if parameters.federal {
                if endpoint.count > 1 {
                    endpoint.append("&")
                }
                endpoint.append("locations=Федеральные")
            }
            if let city = parameters.local {
                if endpoint.count > 1 {
                    endpoint.append("&")
                }
                endpoint.append("locations=\(city)")
            }
            
            return RestApiData(url: url+Constants.Endpoints.settingsLocations+endpoint, httpMethod: .post, parameters: parameters)
        case .saveLocation(let parameters):
            return RestApiData(url: url+Constants.Endpoints.settingsLocations, httpMethod: .put, parameters: parameters)
        case .saveLocalLocation(let parameters):
            return RestApiData(url: url+Constants.Endpoints.settingsLocations, httpMethod: .put, parameters: parameters)
        case .newPhenomenas(let parameters):
            let endpoint = String(format: Constants.Endpoints.newPhenomenas, parameters.eventId)
            return RestApiData(url: url+endpoint, httpMethod: .get, parameters: parameters)
        }
    }
}
