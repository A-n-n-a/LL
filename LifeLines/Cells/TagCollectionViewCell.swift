//
//  OptionCollectionViewCell.swift
//  LifeLines
//
//  Created by Anna on 7/6/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var title: UILabel!
    
    var type: CellType = .topic
    
    var tagTitle: String? {
        didSet {
            setUpCell()
        }
    }
    
    var selectedTag: String?
    
    private func setUpCell() {
        guard let tag = tagTitle else { return }
        container.layer.borderColor = UIColor.kPurpleBorder.cgColor
        container.layer.borderWidth = 1
        title.text = tag.capitalizingFirstLetter()
        
        container.backgroundColor = type == .topic ? UIColor.kBackgroundPurple : .white
        title.font = type == .topic ? UIFont.systemFont(ofSize: 14, weight: .bold) : UIFont.systemFont(ofSize: 12)
        title.textColor = .kPurple96
        
        if selectedTag == tag {
            container.backgroundColor = UIColor.kPurple96
            title.textColor = .white
        }
    }
}

enum CellType {
    case topic
    case tag
}
