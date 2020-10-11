//
//  TagsTutorialView.swift
//  LifeLines
//
//  Created by Anna on 4/25/20.
//  Copyright © 2020 Anna. All rights reserved.
//

import UIKit

class TagsTutorialView: UIView {

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var delegate: TutorialDelegate?
    
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
    
    func setTextViewHeight(textFieldFrame: CGRect) {
        topConstraint.constant = textFieldFrame.minY
        layoutIfNeeded()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        delegate?.dismissTutorialView()
    }
}
