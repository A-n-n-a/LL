//
//  PhenomenaCollectionViewCell.swift
//  LifeLines
//
//  Created by Anna on 7/14/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class PhenomenaCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    var phenomena: Phenomena? {
        didSet {
            setUpCell()
        }
    }
    
    private func setUpCell() {
        guard let phenomena = phenomena else { return }
        title.textColor = phenomena.isSelected ? .kPurple : .kLightPurple
        title.text = phenomena.dateText
        
    }
}
