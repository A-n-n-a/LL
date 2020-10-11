//
//  OptionCollectionViewCell.swift
//  LifeLines
//
//  Created by Anna on 7/6/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class TagViewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var title: UILabel!
    
    var tagTitle: String? {
        didSet {
            setUpCell()
        }
    }
    
    private func setUpCell() {
        guard let tag = tagTitle else { return }
        container.layer.borderColor = UIColor.kLightPurple.cgColor
        container.layer.borderWidth = 1
        title.text = tag.capitalizingFirstLetter()
    }
}
