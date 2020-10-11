//
//  HistoryTableViewCell.swift
//  LifeLines
//
//  Created by Anna on 7/22/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet var queryLabel: UILabel!
    
    var query: String? {
        didSet {
            setUpCell()
        }
    }
    
    func setUpCell() {
        guard let query = query else { return }
        queryLabel.text = query
    }
}
