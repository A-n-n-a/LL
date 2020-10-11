//
//  SwitchTableViewCell.swift
//  LifeLines
//
//  Created by Anna on 7/18/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

protocol SwitchTableViewCellDelegate {
    func switchValueChanged(indexPath: IndexPath, isEnable: Bool)
}

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switcher: UISwitch!
    
    var delegate: SwitchTableViewCellDelegate?
    var indexPath: IndexPath?
    
    var category: Category? {
        didSet {
            setUpCell()
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    func setUpCell() {
        guard let category = category else { return }
        titleLabel.text = category.title
        switcher.setOn(category.isEnable, animated: true)
    }
    
    func setEnable(_ enable: Bool) {
        switcher.setOn(enable, animated: true)
    }
    
    @IBAction func valueChanged(_ sender: UISwitch) {
        guard let indexPath = indexPath else { return }
        delegate?.switchValueChanged(indexPath: indexPath, isEnable: sender.isOn)
    }
    
    @IBAction func switchButtonAction(_ sender: Any) {
        guard let indexPath = indexPath else { return }
        switcher.setOn(!switcher.isOn, animated: true)
        delegate?.switchValueChanged(indexPath: indexPath, isEnable: switcher.isOn)
        
    }
}
