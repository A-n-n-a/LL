//
//  LeftAlignmentFlowLayout.swift
//  LifeLines
//
//  Created by Anna on 7/6/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class LeftAlignmentFlowLayout: UICollectionViewFlowLayout {
    
    var padding: CGFloat = 8
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) ->     [UICollectionViewLayoutAttributes]? {
        guard let oldAttributes = super.layoutAttributesForElements(in: rect) else {
            return super.layoutAttributesForElements(in: rect)
        }
        
        var newAttributes = [UICollectionViewLayoutAttributes]()
        var previousY: CGFloat = 0
        var previousHeight: CGFloat = 0
        var leftMargin = self.sectionInset.left
        for attributes in oldAttributes {
            var newLeftAlignedFrame = attributes.frame
            if (attributes.frame.origin.x == self.sectionInset.left) || attributes.indexPath.item == 0 {
                leftMargin = self.sectionInset.left
                newLeftAlignedFrame.origin.x = leftMargin
                if newLeftAlignedFrame.origin.y == previousY, newLeftAlignedFrame.origin.y != 0 {
                    newLeftAlignedFrame.origin.y += (previousHeight + padding)
                } else if newLeftAlignedFrame.origin.y < previousY {
                    if newLeftAlignedFrame.origin.x == 0, attributes.indexPath.row != 0 {
                        newLeftAlignedFrame.origin.y += (previousHeight + padding)
                    } else {
                        newLeftAlignedFrame.origin.y = previousY
                    }
                }
            } else {
                newLeftAlignedFrame.origin.x = leftMargin 
                if let width = collectionView?.frame.width, (newLeftAlignedFrame.origin.x + attributes.frame.width) > width {
                    newLeftAlignedFrame.origin.x = self.sectionInset.left
                    if newLeftAlignedFrame.origin.y == previousY {
                        newLeftAlignedFrame.origin.y += (previousHeight + padding)

                    } else if newLeftAlignedFrame.origin.y < previousY {
                        newLeftAlignedFrame.origin.y = previousY
                    }
                } else {
                    if newLeftAlignedFrame.origin.y < previousY {
                        newLeftAlignedFrame.origin.y = previousY
                    }
                }
            }
            
            attributes.frame = newLeftAlignedFrame
            leftMargin += attributes.frame.width + padding
            previousY = newLeftAlignedFrame.origin.y
            previousHeight = newLeftAlignedFrame.size.height
            newAttributes.append(attributes)
        }
        return newAttributes
    }
}
