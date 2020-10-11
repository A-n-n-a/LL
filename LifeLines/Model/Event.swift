//
//  Event.swift
//  LifeLines
//
//  Created by Anna on 7/6/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation
import RealmSwift

class Event: Decodable {
    var annotation: String?
    var date: String = ""
    var imageLink: String?
    var sourceName: String?
    var title: String = ""
    var url: String = ""
    var content: String?
    var id: String = ""
    var documentCount: Int?
    var eventCount: Int?
    var locations: [String]?
    var tags = [String]()
    var topics: [String]?
    var documents: [String]?
    var events = [AlternativeEvent]()
    
    var contentHeight: CGFloat?
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        annotation = try? container.decode(String.self, forKey: .annotation)
        date = try container.decode(String.self, forKey: .date)
        imageLink = try? container.decode(String.self, forKey: .imageLink)
        sourceName = try? container.decode(String.self, forKey: .sourceName)
        title = try container.decode(String.self, forKey: .title).trimmingCharacters(in: .whitespacesAndNewlines)
        url = try container.decode(String.self, forKey: .url)
        locations = try? container.decode([String].self, forKey: .locations)
        content = try? container.decode(String.self, forKey: .content)
        id = try container.decode(String.self, forKey: .categorizerId)
        documentCount = try? container.decode(Int.self, forKey: .documentCount)
        eventCount = try? container.decode(Int.self, forKey: .eventCount)
        tags = try container.decode([String].self, forKey: .tags)
        topics = try? container.decode([String].self, forKey: .categories)
        documents = try? container.decode([String].self, forKey: .documents)
        
        if let eventsArray = try? container.decode([AlternativeEvent].self, forKey: .events) {
            events.append(contentsOf: eventsArray)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case annotation
        case date
        case categorizerId
        case imageLink
        case locations
        case sourceName
        case tags
        case title
        case categories
        case url
        case content
        case documentCount
        case documents
        case eventCount
        case events
        
    }
}

extension Event {
    func height() -> CGFloat {
        
        let imageHeight: CGFloat = self.imageLink == nil ? 50 : UIScreen.main.bounds.width / 2
        let paddingToTitle: CGFloat = 50
        let titleHeight: CGFloat = self.title.height(with: UIFont.boldSystemFont(ofSize: 18))
        let paddingToSubtitle: CGFloat = 20
        let subtitleHeight: CGFloat = self.content?.height(with: UIFont.systemFont(ofSize: 15)) ?? 0
        let paddingToTableView: CGFloat = self.events.isEmpty ? 15 : 30
        let tableViewHeight: CGFloat = self.events.isEmpty ? 0 : CGFloat(self.events.count * 90 + 30)
        
        return imageHeight + paddingToTitle + titleHeight + paddingToSubtitle + subtitleHeight + paddingToTableView + tableViewHeight
    }
}

extension Event {
    var isFavorite: Bool {
        return EventsManager.isFavorite(id: self.id)
    }
}
