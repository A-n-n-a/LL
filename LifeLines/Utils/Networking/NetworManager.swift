//
//  NetworkService.swift
//  TapTaxi-New
//
//  Created by Anna on 4/23/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation
import CoreLocation

class NetworkManager {
    
    typealias Completion = ((_ success: Bool, _ error: LLError?) -> Void)?
    typealias CompletionWithStringArray = ((_ string: [String]?, _ error: LLError?) -> Void)?
    typealias CompletionWithEvent = ((_ profile: Event?, _ error: LLError?) -> Void)?
    typealias CompletionWithEvents = ((_ profile: [Event]?, _ error: LLError?) -> Void)?
    typealias CompletionWithCategories = ((_ string: [Category]?, _ error: LLError?) -> Void)?
    typealias CompletionWithCities = ((_ string: [CitiesList]?, _ error: LLError?) -> Void)?
    typealias CompletionWithSettings = ((_ string: SettingsLocations?, _ error: LLError?) -> Void)?
    typealias PhenomenaCompletionWithSettings = ((_ response: NewPhenomenaResponse?, _ error: LLError?) -> Void)?
    
    static func getEvents(keywords: String? = nil, category: String? = nil, hashtag: String? = nil, place: String? = nil, hashtags: [String]? = nil, page: Int? = nil, query: String? = nil, completion: CompletionWithEvents) {
        
        let param = GetAllEventsParameters(keywords: keywords, category: category, place: place, hashtag: hashtag, hashtags: hashtags, page: page, query: query)
        let request = TemplatesAPIRequest.getAllEvents(param)
        URLSessionRestApiManager().call(method: request) { (response: Result<EventsResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.result, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func getSingleEvent(eventId: String, completion: CompletionWithEvent) {
        
        let param = EventIdParameters(eventId: eventId)
        let request = TemplatesAPIRequest.getSingleEvent(param)
        URLSessionRestApiManager().call(method: request) { (response: Result<SingleEventResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.result, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func phenomena(eventId: String, completion: CompletionWithStringArray) {
        
        let param = EventIdParameters(eventId: eventId)
        let request = TemplatesAPIRequest.phenomena(param)
        URLSessionRestApiManager().call(method: request) { (response: Result<PhenomenaResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.result, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func newPhenomena(eventId: String, completion: PhenomenaCompletionWithSettings) {
        
        let param = EventIdParameters(eventId: eventId)
        let request = TemplatesAPIRequest.newPhenomenas(param)
        URLSessionRestApiManager().call(method: request) { (response: Result<NewPhenomenaResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func getFavorites(completion: CompletionWithEvents) {
        
        let param = EmptyParameters()
        let request = TemplatesAPIRequest.getFavorites(param)
        URLSessionRestApiManager().call(method: request) { (response: Result<FavoritesResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.result, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func addFavorite(eventId: String, completion: Completion) {
        
        let param = EventIdParameters(eventId: eventId)
        let request = TemplatesAPIRequest.addFavorite(param)
        URLSessionRestApiManager().call(method: request) { (response: Result<EmptyResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success:
                    completion?(true, nil)
                case .failure(let error):
                    completion?(false, error)
                }
            }
        }
    }
    
    static func deleteFavorite(eventId: String, completion: Completion) {
        
        let param = EventIdParameters(eventId: eventId)
        let request = TemplatesAPIRequest.deleteFavorite(param)
        URLSessionRestApiManager().call(method: request) { (response: Result<EmptyResponse>) in
            switch response {
            case .success:
                completion?(true, nil)
            case .failure(let error):
                completion?(false, error)
            }
        }
    }
    
    static func getCategories(completion: CompletionWithStringArray) {
        
        let param = EmptyParameters()
        let request = TemplatesAPIRequest.categories(param)
        URLSessionRestApiManager().call(method: request) { (response: Result<CategoriesResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.result, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func getLocations(completion: CompletionWithCities) {
        
        let param = EmptyParameters()
        let request = TemplatesAPIRequest.locations(param)
        URLSessionRestApiManager().call(method: request) { (response: Result<LocationsResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.result, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func getSettingsCategories(completion: CompletionWithCategories) {
        
        let param = EmptyParameters()
        let request = TemplatesAPIRequest.settingsCategories(param)
        URLSessionRestApiManager().call(method: request) { (response: Result<SettingsResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    var categories = [Category]()
                    for (key, value) in result.result {
                        categories.append(Category(title: key, isEnable: value))
                    }
                    completion?(categories, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func saveSettingsCategories(category: Category, completion: Completion) {
        
        let param = SaveCategoryParameters(name: category.title, value: category.isEnable)
        let request = TemplatesAPIRequest.saveSettingsCategories(param)
        URLSessionRestApiManager().call(method: request) { (response: Result<EmptyResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success:
                    completion?(true, nil)
                case .failure(let error):
                    completion?(false, error)
                }
            }
        }
    }
    
    static func getSettingsLocations(completion: CompletionWithSettings) {
        
        let param = EmptyParameters()
        let request = TemplatesAPIRequest.getLocations(param)
        URLSessionRestApiManager().call(method: request) { (response: Result<SettingsLocationsResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.result, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func saveLocations(world: Bool, federal: Bool, local: String?, completion: Completion) {
        
        let param = SetLocationParameters(world: world, federal: federal, local: local)
        let request = TemplatesAPIRequest.setLocations(param)
        URLSessionRestApiManager().call(method: request) { (response: Result<BaseBoolResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success:
                    completion?(true, nil)
                case .failure(let error):
                    completion?(false, error)
                }
            }
        }
    }
    
    static func saveLocation(name: String, value: Bool, completion: Completion) {
        
        let param = SaveLocationParameters(name: name, value: value as Any)
        let request = TemplatesAPIRequest.saveLocation(param)
        URLSessionRestApiManager().call(method: request) { (response: Result<EmptyResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success:
                    completion?(true, nil)
                case .failure(let error):
                    completion?(false, error)
                }
            }
        }
    }
    
    static func saveLocalLocation(city: String?, completion: Completion) {
        
        let param = SaveLocalLocationParameters(city: city)
        let request = TemplatesAPIRequest.saveLocalLocation(param)
        URLSessionRestApiManager().call(method: request) { (response: Result<EmptyResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success:
                    completion?(true, nil)
                case .failure(let error):
                    completion?(false, error)
                }
            }
        }
    }
}
