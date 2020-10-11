//
//  SearchTagCollectionViewCell.swift
//  LifeLines
//
//  Created by Anna on 8/17/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class SearchTagCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    var tagTitle: String? {
        didSet {
            setUpCell()
        }
    }
    
    func setUpCell() {
        titleLabel.text = tagTitle?.capitalizingFirstLetter()
    }
}
