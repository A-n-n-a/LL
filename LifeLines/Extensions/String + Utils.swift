//
//  String + Utils.swift
//  LifeLines
//
//  Created by Anna on 7/13/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

extension String {
    func changeDateFormat(from format1: String, to format2: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format1
        dateFormatter.locale = Locale.init(identifier: "ru_RU")
        
        let date = dateFormatter.date(from: self)
        
        dateFormatter.dateFormat = format2
        if let date = date {
            let string = dateFormatter.string(from: date)
            return string
        }
        return nil
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func toDateWith(format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale.init(identifier: "ru_RU")
        
        let date = dateFormatter.date(from: self)
        return date
    }
    
    func attributedStringWith(font: UIFont?,
                              color: UIColor,
                              lineHeight: CGFloat = 0,
                              alignment: NSTextAlignment = .left,
                              lineBreakMode: NSLineBreakMode = .byTruncatingTail) -> NSAttributedString? {
        guard let font = font else {
            assertionFailure("Error creating attributed string. Reason: provided font is nil. \nString: \(self)")
            return nil
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode
        
        if lineHeight != 0 {
            paragraphStyle.minimumLineHeight = lineHeight
        }
        
        let attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle,
                                                         .font: font,
                                                         .foregroundColor: color]
        let attributedString = NSAttributedString(string: self, attributes: attributes)
        
        return attributedString
    }
    
    func height(with font: UIFont) -> CGFloat {
        let width = UIScreen.main.bounds.width // - 30
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func nounCapitalized() -> String {
        var output = ""
        let words = self.components(separatedBy: " ")
        for word in words {
            if word.count == 1 {
                output += "\(word) "
            } else {
                output += "\(word.capitalized) "
            }
        }
        return output
    }
}
