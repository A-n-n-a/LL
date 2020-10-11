//
//  UIDevice + Utils.swift
//  LifeLines
//
//  Created by Anna on 9/22/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

extension UIDevice {
    func isFrameless() -> Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
}
