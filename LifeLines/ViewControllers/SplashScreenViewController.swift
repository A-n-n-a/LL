//
//  SplashScreenViewController.swift
//  LifeLines
//
//  Created by Anna on 7/7/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit
import RealmSwift

class SplashScreenViewController: LLViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getEvents()
        getCategories()
        getLocations()
        getSettingsLocations()
        getFavorites()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func getEvents() {
        NetworkManager.getEvents() { (events, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.showError(error)
                }
                if let events = events {
                    EventsManager.events = events
                    
                    let rootViewController = UIApplication.shared.keyWindow?.rootViewController
                    guard let rootNC = rootViewController as? UINavigationController,
                        let tabBarVC = UIStoryboard.get(flow: .tabBar).get(controller: .tabBarVC) as? MainTabBarViewController else {
                                                        return
                    }
                    
                    rootNC.dismiss(animated: true, completion: nil)
                    rootNC.setViewControllers([tabBarVC], animated: true)
                    _ = tabBarVC.view
                    tabBarVC.selectedIndex = 0
                }
            }
        }
    }
    
    func getCategories() {
        NetworkManager.getSettingsCategories { (categories, _) in
            DispatchQueue.main.async {
                if let categories = categories {
                    RealmManager.addOrUpdate(objects: categories)
                }
            }
        }
    }
    
    func getLocations() {
            
        NetworkManager.getLocations { (citiesList, _) in
            guard let citiesList = citiesList else { return }
            var popularCities = [String]()
            var commonCities = [String]()
            for list in citiesList {
                if list.header != nil {
                    commonCities.append(contentsOf: list.cities)
                } else {
                    popularCities.append(contentsOf: list.cities)
                }
            }
            let cities = popularCities + commonCities
            SettingsManager.cities = cities
        }
    }
    
    func getFavorites() {
        NetworkManager.getFavorites { [weak self] (favorites, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error)
                }
                if let favorites = favorites {
                    EventsManager.favorites = favorites
                }
            }
        }
    }
}
