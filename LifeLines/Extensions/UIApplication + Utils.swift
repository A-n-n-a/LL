//
//  UIApplication + Utils.swift
//  LifeLines
//
//  Created by Anna on 9/11/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

extension UIApplication {
    
    class func topViewController(_ base: UIViewController?
        = UIApplication.shared.keyWindow?.rootViewController) -> LLViewController? {
        
        if let navigationController = base as? UINavigationController, navigationController.viewControllers.count > 0 {
            return topViewController(navigationController.visibleViewController)
        }
        
        if let tabBarController = base as? UITabBarController {
            if let selected = tabBarController.selectedViewController {
                return topViewController(selected)
            }
        }
        
        if let presentedViewController = base?.presentedViewController {
            return topViewController(presentedViewController)
        }
        
        return base as? LLViewController
    }
}
