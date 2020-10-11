//
//  HintTableViewCell.swift
//  LifeLines
//
//  Created by Anna on 7/28/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class HintTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var hint: String? {
        didSet {
            titleLabel.text = hint
        }
    }

}
