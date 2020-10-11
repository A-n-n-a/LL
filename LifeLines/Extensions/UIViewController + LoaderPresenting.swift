//
//  UIViewController + LoaderPresenting.swift
//  LifeLines
//
//  Created by Anna on 7/18/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

protocol LoaderPresenting {
    var loader: LoaderView { get }
    
    func showLoader(on view: UIView?, text: String?)
    func dismissLoader()
}

extension LoaderPresenting where Self: UIViewController {
    //=========================================================
    // MARK: - Public
    //=========================================================
    /// Show loader
    ///
    /// - Parameter text: visible text on loader
    func showLoader(on view: UIView? = nil, text: String? = nil) {
        loader.text = text
        
        if let view = view {
            view.backgroundColor = .red
            view.addSubviewUsingConstraints(view: loader, insets: UIEdgeInsets(top: 72, left: 0, bottom: 0, right: 0))
        } else {
            self.view.addSubviewUsingConstraints(view: loader, insets: UIEdgeInsets(top: 72, left: 0, bottom: 0, right: 0))
        }
        
        loader.startAnimating()
    }
    
    /// Dismiss loader
    func dismissLoader() {
        loader.stopAnimating()
        loader.removeFromSuperview()
    }
    
}
