//
//  MainTabBarViewController.swift
//  Portmone
//
//  Created by Memento Mori on 9/4/17.
//  Copyright © 2017 Devlight. All rights reserved.
//

import UIKit

enum MainTabBarTabs: Int {
    case events = 0, search, favorites, settings
}

final class MainTabBarViewController: UITabBarController {
    
    //=========================================================
    // MARK: - ViewController LifeCycle
    //=========================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupControllers()
    }
    
    //=========================================================
    // MARK: - Configuration
    //=========================================================
    private func setupAppearance() {
        // Setup TabBar background
        self.tabBar.barTintColor = UIColor.white
        self.tabBar.isTranslucent = false
        
        // Setup TabBar item styles
        let normalFont = UIFont.systemFont(ofSize: 10, weight: .bold)
        
        let normalColor = UIColor.kLightPurple
        let selectedColor = UIColor.kPurple
        
        tabBar.unselectedItemTintColor = normalColor
        tabBar.tintColor = selectedColor
        
        let attrsNormal: [NSAttributedString.Key: Any] = [.foregroundColor: normalColor,
                                                         .font: normalFont]
        let attrsSelected: [NSAttributedString.Key: Any] = [.foregroundColor: selectedColor,
                                                           .font: normalFont]
        
        // Selected font attribute is not working
        UITabBarItem.appearance().setTitleTextAttributes(attrsNormal, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(attrsSelected, for: .selected)
    }
    
    private func setupControllers() {
        let events = setupEventsFlow()
        let search = setupSearchFlow()
        let favorites = setupFavoritesFlow()
        let settings = settingsFlow()
        
        // Initialize Tabs
        self.viewControllers = [events, search, favorites, settings]
    }
    
    private func setupEventsFlow() -> UIViewController {
        let eventsVC = UIStoryboard.instantiateFlow(.eventsFlow)
        eventsVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Пульс", comment: ""),
                                         image: #imageLiteral(resourceName: "icPulse"),
                                         tag: MainTabBarTabs.events.rawValue)
        
        return eventsVC
    }
    
    private func setupSearchFlow() -> UIViewController {
        let searchNavVC = UIStoryboard.instantiateFlow(.searchFlow) as! UINavigationController
        //swiftlint:disable:previous force_cast
        searchNavVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Поиск", comment: ""),
                                             image: #imageLiteral(resourceName: "icSearch"),
                                             tag: MainTabBarTabs.search.rawValue)
        
        if let searchVC = UIStoryboard.get(flow: .searchFlow).get(controller: .searchVC) as? SearchViewController {
            searchVC.hidesBottomBarWhenPushed = false
            searchNavVC.setViewControllers([searchVC], animated: false)
        }
        
        return searchNavVC
    }
    
    private func setupFavoritesFlow() -> UIViewController {
        let favoritesNavVC = UIStoryboard.instantiateFlow(.favoritesFlow) as! UINavigationController
        //swiftlint:disable:previous force_cast
        favoritesNavVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Избранное", comment: ""),
                                             image: #imageLiteral(resourceName: "icFavor"),
                                             tag: MainTabBarTabs.favorites.rawValue)
        
        if let favoritesVC = UIStoryboard.get(flow: .favoritesFlow)
            .get(controller: .favoritesVC) as? FavoritesViewController {
            favoritesVC.hidesBottomBarWhenPushed = false
            favoritesNavVC.setViewControllers([favoritesVC], animated: false)
        }
        
        return favoritesNavVC
    }
    
    private func settingsFlow() -> UIViewController {
        let settingsNavVC = UIStoryboard.instantiateFlow(.settingsFlow) as! UINavigationController
        //swiftlint:disable:previous force_cast
        settingsNavVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Настройки", comment: ""),
                                             image: #imageLiteral(resourceName: "icSetting"),
                                             tag: MainTabBarTabs.settings.rawValue)
        
        if let settingsVC = UIStoryboard.get(flow: .settingsFlow).get(controller: .settingsVC) as? SettingsViewController {
            settingsVC.hidesBottomBarWhenPushed = false
            settingsNavVC.setViewControllers([settingsVC], animated: false)
        }
        return settingsNavVC
    }
}

extension UIViewController {
    var mainTabBarController: MainTabBarViewController? {
        return tabBarController as? MainTabBarViewController
    }
}
