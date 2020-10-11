//
//  LoaderView.swift
//  LifeLines
//
//  Created by Anna on 7/6/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

final class LoaderView: UIView {
    //=========================================================
    // MARK: - Variables, Constants and Outlets
    //=========================================================
    private let defaultLoaderText = NSLocalizedString("Загрузка...\nПодождите, пожалуйста", comment: "")
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var textLabel: UILabel!
    
    /// Set title text
    public var text: String? {
        set {
            setAttributedText(newValue ?? defaultLoaderText)
        }
        get {
            return textLabel.attributedText?.string
        }
    }
    
    /// A Boolean value indicating whether the activity indicator is currently running its animation.
    public var isAnimating: Bool {
        return activityIndicator.isAnimating
    }
    
    //=========================================================
    // MARK: - Initialization
    //=========================================================
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    //=========================================================
    // MARK: - Private functions
    //=========================================================
    private func setup() {
        addSelfNibUsingConstraints()
        
        setAttributedText(text ?? defaultLoaderText)
    }
    
    private func setAttributedText(_ text: String) {        
        textLabel.attributedText = text.attributedStringWith(font: .systemFont(ofSize: 16),
                                                             color: .kLightPurple,
                                                             lineHeight: 22,
                                                             alignment: .center)
    }
    
    //=========================================================
    // MARK: - Public functions
    //=========================================================
    /// Starts the animation of the activity indicator.
    public func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    /// Stops the animation of the activity indicator.
    public func stopAnimating() {
        activityIndicator.stopAnimating()
    }
    
}
