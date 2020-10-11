//
//  TableBackgroundView.swift
//  LifeLines
//
//  Created by Anna on 7/7/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

final class TableBackgroundView: UIView {
    //=========================================================
    // MARK: - Variables, Constants and Outlets
    //=========================================================
    @IBOutlet private var backgroundView: UIView!
    @IBOutlet private var stack: UIStackView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var imageCenterYCnstr: NSLayoutConstraint!
    @IBOutlet private var bottomView: UIView!
    @IBOutlet private var bottomCnstr: NSLayoutConstraint!
    @IBOutlet private var payByRequisitesButton: UIButton!
    @IBOutlet private var bottomButton: UIButton!
    
    var scrollOffset: CGFloat = 0
    
    var offsetY: CGFloat = 0 {
        willSet {
            NSLayoutConstraint.activate([stack.topAnchor.constraint(equalTo: topAnchor, constant: newValue)])
        }
    }
    
    var canBeHidden: Bool {
        return scrollOffset >= 0
    }
    
    var needToBeHidden: Bool = false
    
    var centerY: CGFloat = 0 {
        willSet {
            imageCenterYCnstr.constant = newValue
//            NSLayoutConstraint.activate([stack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: newValue)])
        }
    }
    
    var customOffset: CGFloat = 0
    
    //=========================================================
    // MARK: - Initialization
    //=========================================================
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        prepareUI()
    }
    
    init(image: UIImage, titleText: String) {
        self.init()
        self.imageView.image = image
        self.titleLabel.text = titleText
    }
    
    func prepareUI() {
        addSelfNibUsingConstraints()
    }
    
    func addView(_ view: UIView) {
        stack.addArrangedSubview(view)
    }
    
    func set(image: UIImage?, template: Bool = false) {
        let mode: UIImage.RenderingMode = template ? .alwaysTemplate : .alwaysOriginal
        imageView.image = image?.withRenderingMode(mode)
        imageView.tintColor = UIColor.kLightPurple
    }
    
    func setTitleText(_ text: String?) {
        guard let text = text else {
            return
        }
        let attributed = text.attributedStringWith(font: UIFont.systemFont(ofSize: 22, weight: .medium),
                                                   color: .kLightPurple, lineHeight: 24,
                                                   alignment: .center, lineBreakMode: .byWordWrapping)
        titleLabel.attributedText = attributed
    }
    
    func setSubtitleText(_ text: String?) {
        guard let text = text else {
            return
        }
        let attributed = text.attributedStringWith(font: UIFont.systemFont(ofSize: 15),
                                                   color: .kLightPurple, lineHeight: 20,
                                                   alignment: .center, lineBreakMode: .byWordWrapping)
        subtitleLabel.attributedText = attributed
    }
    
    func setBottomButton(title: String, action: Selector, target: Any?) {
        bottomButton.addTarget(target, action: action, for: .touchUpInside)
        bottomButton.setTitle(title, for: .normal)
        bottomButton.isHidden = false
    }
    
    func setBackgroundColor(_ color: UIColor) {
        self.backgroundView.backgroundColor = color
    }
    
    func setButtonHidden(_ hide: Bool) {
        payByRequisitesButton.isHidden = hide
    }
    
    func setImageHidden(_ hide: Bool) {
        imageView.isHidden = hide
    }
    
    func updateOpacityWith(contentOffset: CGFloat) {
        scrollOffset = contentOffset
        var opacity = -scrollOffset
        opacity = (1 - opacity / 25)
        alpha = needToBeHidden ? 0 : opacity

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: nil, object: nil)
    }
}
