//
//  StoryboardHelper.swift
//  LifeLines
//
//  Created by Anna on 7/6/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

// Storyboard Files
enum StoryboardFlow: String {
    case tabBar = "MainTabBarInterface"
    case eventsFlow = "EventsFlow"
    case searchFlow = "SearchFlow"
    case favoritesFlow = "FavoritesFlow"
    case settingsFlow = "SettingsFlow"
}

// ViewController Storyboard ID's
enum StoryboardControllerID: String {
    case tabBarVC = "mainTabBarVC"
    case eventsVC = "eventsVC"
    case searchVC = "searchVC"
    case favoritesVC = "favoritesVC"
    case settingsVC = "settingsVC"
    case singleEventVC = "singleEventVC"
    case categoriesVC = "categoriesVC"
    case locationsVC = "locationsVC"
    case citiesVC = "citiesVC"
    case hashTagEventsVC = "hashTagEventsVC"
    case eventsByTagVC = "eventsByTagVC"
    case searchResultsVC = "searchResultsVC"
}

extension UIStoryboard {
    
    class func get(flow: StoryboardFlow) -> UIStoryboard {
        return UIStoryboard(name: flow.rawValue, bundle: nil)
    }
    
    class func instantiateFlow(_ flow: StoryboardFlow) -> UIViewController {
        let flowSB = UIStoryboard.get(flow: flow)
        let initialVC = flowSB.instantiateInitialViewController()! //swiftlint:disable:this force_unwrapping
        
        return initialVC
    }
    
    func get(controller controllerID: StoryboardControllerID) -> UIViewController {
        return self.instantiateViewController(withIdentifier: controllerID.rawValue)
    }
    
}
