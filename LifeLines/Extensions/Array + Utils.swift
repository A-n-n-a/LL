//
//  Array + Utils.swift
//  LifeLines
//
//  Created by Anna on 11/10/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating private func move(_ item: Element, to newIndex: Index) {
        if let index = firstIndex(of: item) {
            move(at: index, to: newIndex)
        }
    }

    mutating func bringToFront(item: Element) {
        move(item, to: 0)
    }
    
    mutating private func move(at index: Index, to newIndex: Index) {
        insert(remove(at: index), at: newIndex)
    }
}
