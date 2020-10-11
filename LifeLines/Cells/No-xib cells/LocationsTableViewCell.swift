//
//  LocationsTableViewCell.swift
//  LifeLines
//
//  Created by Anna on 7/21/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class LocationsTableViewCell: UITableViewCell {

    @IBOutlet weak var localLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var switcher: UISwitch!
    
    var delegate: SwitchTableViewCellDelegate?
    var indexPath: IndexPath?
    
    var category: Category? {
        didSet {
            setUpCell()
        }
    }
    
    func setUpCell() {
        guard let category = category else { return }
//        titleLabel.text = category.title
        switcher.setOn(category.isEnable, animated: true)
    }

    @IBAction func valueChanged(_ sender: UISwitch) {
        guard let indexPath = indexPath else { return }
        delegate?.switchValueChanged(indexPath: indexPath, isEnable: sender.isOn)
    }
}
