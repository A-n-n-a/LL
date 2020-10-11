//
//  SettingsTutorialView.swift
//  LifeLines
//
//  Created by Anna on 4/25/20.
//  Copyright © 2020 Anna. All rights reserved.
//

import UIKit

class SettingsTutorialView: UIView {

    @IBOutlet weak var topCategoryConstraint: NSLayoutConstraint!
    @IBOutlet weak var topLocationConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
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
        
        setTopConstraint()
    }
    
    func setTopConstraint() {
        var offset = UIApplication.shared.statusBarFrame.height + 60 + 50
        topCategoryConstraint.constant = offset
        offset += 60
        topLocationConstraint.constant = offset
        layoutIfNeeded()
    }
    
    @IBAction func switchHint(_ sender: Any) {
        if pageControl.currentPage == 0 {
            nextButton.setTitle("Продолжить", for: .normal)
            pageControl.currentPage = 1
            categoryView.isHidden = true
            locationView.isHidden = false
        } else {
            delegate?.dismissTutorialView()
        }
    }
}
