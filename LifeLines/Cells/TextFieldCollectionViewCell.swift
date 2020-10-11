//
//  TextFieldCollectionViewCell.swift
//  LifeLines
//
//  Created by Anna on 4/2/20.
//  Copyright © 2020 Anna. All rights reserved.
//

import UIKit

class TextFieldCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var textField: UITextField!
    
    func setDelegate(_ delegate: UITextFieldDelegate) {
        textField.delegate = delegate
    }
    
    func setFirstResponder() {
        textField.becomeFirstResponder()
    }
}
