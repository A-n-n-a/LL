//
//  SettingsTableViewCell.swift
//  LifeLines
//
//  Created by Anna on 7/18/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var section: SettingsSection? {
        didSet {
            setUpCell()
        }
    }

    func setUpCell() {
        guard let section = section else { return }
        icon.image = section.image
        titleLabel.text = section.title
        subtitleLabel.isHidden = section.categories.isEmpty
        if section.settingsType == .categories, SettingsManager.allCategoriesSelected {
            subtitleLabel.text = "Все темы"
        } else {
            subtitleLabel.text = section.categories.joined(separator: ", ")
        }
    }
}
