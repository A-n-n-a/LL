//
//  UICollectionView + Utils.swift
//  LifeLines
//
//  Created by Anna on 7/6/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

extension UICollectionView {
    func registerCell(for cellClass: AnyClass) {
        let bundle = Bundle(for: cellClass)
        let nib = UINib(nibName: String(describing: cellClass), bundle: bundle)
        self.register(nib, forCellWithReuseIdentifier: String(describing: cellClass))
    }
    
    func reloadData(completion: @escaping () -> Void) {
        UIView.animate({
            self.reloadData()
        }) {
            completion()
        }
    }
}
