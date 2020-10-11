//
//  CityTableViewCell.swift
//  LifeLines
//
//  Created by Anna on 7/26/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

protocol CityTableViewCellDelegate {
    func citySelected(indexPath: IndexPath, searchMode: Bool)
}

class CityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var checkBox: UIImageView!
    
    var delegate: CityTableViewCellDelegate?
    var indexPath: IndexPath?
    var searchMode = false
    
    var city: String! {
        didSet {
            setUpCell()
        }
    }
    
    var isLastCity = false
    var isEnable = false 
    
    func setUpCell() {
        
        titleLabel.isHidden = !isLastCity
        cityLabel.text = city
        checkBox.image = isEnable ? #imageLiteral(resourceName: "icCheckAct") : #imageLiteral(resourceName: "ic-check-noact")
    }
    
    @IBAction func setCheckBoxSelected(_ sender: Any) {
        guard let indexPath = indexPath else { return }
        isEnable = true
        delegate?.citySelected(indexPath: indexPath, searchMode: searchMode)
    }
}
