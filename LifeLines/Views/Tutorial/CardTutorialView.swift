//
//  CardTutorialView.swift
//  LifeLines
//
//  Created by Anna on 4/25/20.
//  Copyright © 2020 Anna. All rights reserved.
//

import UIKit

class CardTutorialView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUpView()
    }

    
    func setUpView() {
        addSelfNibUsingConstraints()
    }
}
