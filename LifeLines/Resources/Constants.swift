//
//  Constants.swift
//  TapTaxi-Client
//
//  Created by Anna on 4/21/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation
import UIKit

class Constants {

    struct Links {
//        static let baseURL = "http://89.208.198.107:8081/"
        static let baseURL = "http://point.lifelines.name:8081/"
    }

    struct Endpoints {
        static let singleEvent = "event"
        static let phenomena = "phenomena"
        static let favorites = "favorites"
        static let categories = "categories"
        static let locations = "locations"
        static let settingsCategories = "settings/categories"
        static let settingsLocations = "settings/locations"
        static let newPhenomenas = "api/v3/events/%@/phenomena"
    }

    struct DateFormats {
        static let titleFormat = "EEEE, dd MMM"
        static let titleFormatFull = "EEEE, dd MMMM yyyy"
        static let eventDateFormat = "yyyy-MM-dd"
        static let carouselFormat = "dd.MM.yyyy"
    }
    
    enum RealmManualMigrationVersion: UInt64 {
        case addCities = 3
        case clearDataBase = 7
    }
    
    struct Keys {
        static let udCardTutorialWasShown = "udCardTutorialWasShown"
        static let udTagsTutorialWasShown = "udTagsTutorialWasShown"
        static let udPulseTutorialWasShown = "udPulseTutorialWasShown"
        static let udSettingsTutorialWasShown = "udSettingsTutorialWasShown"
        static let udWasLaunched = "udWasLaunched"
        static let watchesCount = "udWatchesCount"
    }
    
    struct Events {
        static let sessionStart = "Session start"
        static let firstLaunch = "Launch first time"
        static let newsViewed = "News viewed"
        static let watchedPrevious = "Watched the previous news"
        static let addToFavorite = "Add to Favorites"
        static let pressedTag = "Pressed tag"
        static let deletedTag = "Deleted tag"
        static let pageUpdate = "Page update"
        static let switchToSource = "Switching to a news source"
        static let newsSharing = "News sharing"
        static let startSearch = "Search started entering a search query"
        static let searchClicked = "Search clicked on search"
        static let searchCompleted = "Search completed"
        static let favoritesAreViewed = "Favorites are viewed"
        static let tagSearchInFavorites = "Tag search in Favorites"
        static let newsDeletedInFavorites = "News deleted in Favorites"
        static let locationSelected = "Location selected"
        static let topicSelected = "Topic selected"
        static let trackNotificationClicked = "Track Notification Clicked"
        static let subject = "Clicked on the subject and moved on to the news"
    }
    
    struct Parameters {
        static let place = "place"
        static let pulse = "pulse"
        static let searchResults = "search results"
        static let tagSearchResults = "tag search results"
        static let favorites = "favorites"
        static let suggestions = "suggestions"
        static let news = "news"
        static let empty = "empty"
        static let world = "общемировые"
        static let federal = "федеральные"
        static let local = "локальные"
        static let notificationId = "notificationId"
        
        static let cohortDay = "сohort day"
        static let cohortWeek = "cohort week"
        static let cohortMonth = "cohort month"
    }
    
    struct Height {
        static let nativeAdHeight: CGFloat = 380
    }
}
