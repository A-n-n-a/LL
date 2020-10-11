//
//  UIView + Utils.swift
//  LifeLines
//
//  Created by Anna on 7/7/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 0.5
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.layer.removeAllAnimations()
        }
    }
    
    class func animate(_ animations: @escaping (() -> Void), completion: (() -> Void)? = nil) {
        UIView.animate(withDecision: true,
                       animations: animations,
                       completion: completion)
    }
    
    class func animate(withDecision isAnimated: Bool,
                       animations: @escaping (() -> Void),
                       completion: (() -> Void)? = nil) {
        guard isAnimated else {
            animations()
            completion?()
            return
        }
        
        let parameters = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.230, y: 1.000),
                                                 controlPoint2: CGPoint(x: 0.320, y: 1.000))
        
        let animator = UIViewPropertyAnimator(duration: TimeInterval(0.5),
                                              timingParameters: parameters)
        animator.addAnimations(animations)
        animator.addCompletion { _ in
            completion?()
        }
        animator.startAnimation()
    }
    
    // Add Self Nibfile
    @discardableResult
    func addSelfNibUsingConstraints(nibName: String) -> UIView? {
        guard let nibView = loadSelfNib(nibName: nibName) else {
            assert(true, "---- UIView Extension Nib file not found ----")
            return nil
        }
        
        addSubviewUsingConstraints(view: nibView)
        return nibView
    }
    
    @discardableResult
    func addSelfNibUsingConstraints() -> UIView? {
        guard let nibView = loadSelfNib() else {
            assert(true, "---- UIView Extension Nib file not found ----")
            return nil
        }
        
        addSubviewUsingConstraints(view: nibView)
        return nibView
    }
    
    // Load Nibfile
    func loadSelfNib() -> UIView? {
        let nibName = String(describing: type(of: self))
        if let nibFiles = Bundle.main.loadNibNamed(nibName, owner: self, options: nil),
            nibFiles.count > 0 {
            return nibFiles.first as? UIView
        }
        return nil
    }
    
    func loadSelfNib(nibName: String) -> UIView? {
        if let nibFiles = Bundle.main.loadNibNamed(nibName, owner: self, options: nil), nibFiles.count > 0 {
            return nibFiles.first as? UIView
        }
        return nil
    }
    
    // Add subview
    func addSubviewUsingConstraints(view: UIView,
                                    insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        NSLayoutConstraint.activate([view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
                                     view.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
                                     trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: insets.right),
                                     bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom)])
    }
}
