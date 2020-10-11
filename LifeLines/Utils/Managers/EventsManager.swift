//
//  EventsManager.swift
//  LifeLines
//
//  Created by Anna on 7/7/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation

class EventsManager {
    
    static var events = [Event]() 
    
    static func decryptedContent(_ content: String) -> NSMutableAttributedString? {
        let styles =
            "<style>" +
                "div { background-color:transparent !important; }" +
                "a { display:none !important; }" +
                "p a { display:inline !important; }" +
                "table td tr td { padding: 5px 5px !important; }" +
                "p, ul {margin: 5px 0; }" +
                "table td td[align='right'] { width: 140px !important; }" +
        "</style>"
        
        let source = styles + content
        var decryptedHTMLText: NSMutableAttributedString?
        //decrypt HTML text
        if let data = source.data(using: String.Encoding.utf8) {
            decryptedHTMLText = try? NSMutableAttributedString(
                data: data,
                options: [
                    .documentType: NSMutableAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil)
        }
        return decryptedHTMLText
    }
    
    static var favorites = [Event]()
    static var favoritesNeedUpdate = false
    
    static func addFavorite(_ favorite: Event) {
        favorites.insert(favorite, at: 0)
        favoritesNeedUpdate = true
    }
    
    static func removeFromFavorites(_ event: Event) {
        EventsManager.removeFromFavorites(id: event.id)
        AnalyticsManager.shared.logEvent(name: Constants.Events.newsDeletedInFavorites)
    }
    
    static func removeFromFavorites(id: String) {
        for (index, favorite) in EventsManager.favorites.enumerated() {
            if favorite.id == id {
                EventsManager.favorites.remove(at: index)
                favoritesNeedUpdate = true
                AnalyticsManager.shared.logEvent(name: Constants.Events.newsDeletedInFavorites)
            }
        }
    }
    
    static func isFavorite(id: String) -> Bool {
        var isFav = false
        for favorite in EventsManager.favorites {
            if favorite.id == id {
                isFav = true
            }
        }
        return isFav
    }
}
