//
//  ArticleTableViewCell.swift
//  LifeLines
//
//  Created by Anna on 8/16/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    
    var event: AlternativeEvent? {
        didSet {
            setUpCell()
        }
    }
    
    func setUpCell() {
        
        guard let event = event else { return }
        
        titleLabel.text = event.title
        sourceLabel.text = event.sourceName
    }
}
