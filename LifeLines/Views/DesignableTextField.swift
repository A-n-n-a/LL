//
//  DesignableTextField.swift
//  LifeLines
//
//  Created by Anna on 7/22/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableTextField: UITextField {
    
    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var leftPadding: CGFloat = 0
    
    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let image = leftImage {
            leftViewMode = UITextField.ViewMode.always
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
            let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 16, height: 16))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            
            containerView.addSubview(imageView)
            leftView = containerView
        } else {
            leftViewMode = UITextField.ViewMode.never
            leftView = nil
        }
        
        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[.foregroundColor: color,
                            .font: UIFont.systemFont(ofSize: 16)])
    }
}
