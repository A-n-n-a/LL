//
//  Date + Utils.swift
//  LifeLines
//
//  Created by Anna on 7/6/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation

extension Date {
    public func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ru_Ru")
        return formatter.string(from: self)
    }
    
    func numberOfDays() -> Int? {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let components = DateComponents(year: year, month: 1, day: 1)
        guard let newYear = calendar.date(from: components) else { return nil}
        let days = calendar.dateComponents([.day], from: newYear, to: Date())
        return days.day
    }
}
