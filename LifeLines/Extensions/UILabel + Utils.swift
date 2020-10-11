//
//  UILabel + Utils.swift
//  LifeLines
//
//  Created by Anna on 11/1/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    func calculateMaxLines(width: CGFloat? = nil) -> Int {
        var labelWidth: CGFloat = frame.width
        if let width = width {
            labelWidth = width
        }
        let maxSize = CGSize(width: labelWidth, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font as Any], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}
