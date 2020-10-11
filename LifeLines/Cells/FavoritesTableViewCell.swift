//
//  FavoritesTableViewCell.swift
//  LifeLines
//
//  Created by Anna on 7/21/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    
    var event: Event? {
        didSet {
            setUpCell()
        }
    }
    
    var delegate: OpenURLDelegate?

    func setUpCell() {
        guard let event = event else { return }
        titleLabel.text = event.title
        sourceLabel.text = event.sourceName
    }
    
    @IBAction func openUrl(_ sender: Any) {
        guard let urlString = event?.url, let url = URL(string: urlString) else { return }
        delegate?.open(url: url)
    }
}
