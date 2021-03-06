//
//  NativeView.swift
//  AppodealSwiftDemo
//
//  Copyright © 2017 appodeal. All rights reserved.
//

import UIKit
import Appodeal


final class NativeView: UIView {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var callToAction: UILabel!

    @IBOutlet weak var descr: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var mediaContainer: UIView!
    @IBOutlet weak var adChoices: UIView!
    
    @IBOutlet weak var shadowView: UIView!
    
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        
        self.icon.layer.cornerRadius = 8.0
        self.icon.layer.masksToBounds = true

        self.callToAction.layer.cornerRadius = 8.0
        self.callToAction.layer.masksToBounds = true
        
        setShadow()
    }
    
    func setShadow() {
        shadowView.layer.shadowColor = UIColor.kShadow.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 6)
        shadowView.layer.shadowOpacity = 0.25
        shadowView.layer.shadowRadius = 10
    }
}

extension NativeView : APDNativeAdView {
    func titleLabel() -> UILabel {
        return title
    }
    
    func callToActionLabel() -> UILabel {
        return callToAction
    }
    
    func descriptionLabel() -> UILabel {
        return descr
    }
    
    func iconView() -> UIImageView {
        return icon
    }
    
    func mediaContainerView() -> UIView {
        return mediaContainer
    }
    
    func adChoicesView() -> UIView {
        return adChoices
    }
    
    static func nib() -> UINib {
        return UINib.init(nibName: "Native", bundle: Bundle.main)
    }
}

