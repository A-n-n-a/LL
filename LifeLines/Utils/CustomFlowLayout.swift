//
//  CustomFlowLayout.swift
//  LifeLines
//
//  Created by Anna on 7/14/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

final class CustomFlowLayout: UICollectionViewFlowLayout {
    
    var itemsCount = 0
    
    var currentIndexPath: IndexPath?
    
    private let itemWidth: CGFloat = 195
    private var previousOffset: CGFloat = 0
    
    //*****************************************************************************/
    // MARK: - Initialization
    //*****************************************************************************/
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    override init() {
        super.init()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //*****************************************************************************/
    // MARK: - Setting up
    //*****************************************************************************/
    func setup() {
        self.scrollDirection = .horizontal
        
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        headerReferenceSize = CGSize.zero
    }
    
    //*****************************************************************************/
    // MARK: - Layout Updating
    //*****************************************************************************/
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = self.collectionView else {
            return proposedContentOffset
        }
        
        let visiblePart = (UIScreen.main.bounds.width - itemWidth) / 2
        let invisiblePart = itemWidth - visiblePart

        var point = CGPoint(x: 0, y: proposedContentOffset.y)

        if velocity.x >= 0 && proposedContentOffset.x >= (previousOffset) {
            if currentIndexPath?.item != (itemsCount - 1) {
                currentIndexPath?.item += 1
            }
        } else if proposedContentOffset.x <= (previousOffset) {
            if currentIndexPath?.item != 0 {
                currentIndexPath?.item -= 1
            }
        }
    
        var offset: CGFloat = 0
        if let currentIndexPath = currentIndexPath, currentIndexPath.item > 0 {
            offset = CGFloat(max(0, currentIndexPath.item - 1)) * itemWidth + invisiblePart
        }

        previousOffset = offset
        point.x = offset

        if let currentIndexPath = currentIndexPath {
            collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: currentIndexPath)
        }

        return point
    }
}

