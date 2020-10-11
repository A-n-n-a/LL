//
//  Phenomena.swift
//  LifeLines
//
//  Created by Anna on 7/14/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation

class Phenomena {
    var dateText: String
    var event: Event
    var isSelected: Bool = false
    
    init(event: Event, isSelected: Bool = false) {
        self.event = event
        self.isSelected = isSelected
        
        let stringDate = event.date.changeDateFormat(from: Constants.DateFormats.eventDateFormat, to: Constants.DateFormats.carouselFormat)
        if let date = stringDate?.toDateWith(format: Constants.DateFormats.carouselFormat), Calendar.current.isDateInToday(date) {
            self.dateText = "Сегодня"
        } else if let stringDate = stringDate {
            self.dateText = "Coбытие от \(stringDate)"
        } else {
            self.dateText = ""
        }
    }
}


struct NewPhenomenaResponse: Decodable {
    let tags: [String]
    let events: [NewPhenomena]
}

struct NewPhenomena: Decodable {
    let id: String
    let date: String
}
