//
//  SettingsViewController.swift
//  LifeLines
//
//  Created by Anna on 7/6/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var sections = [SettingsSection(image: #imageLiteral(resourceName: "ic-add-fav-1"), title: "Темы событий", categories: [], settingsType: .categories),
                    SettingsSection(image: #imageLiteral(resourceName: "ic-add-fav-2"), title: "География событий", categories: [], settingsType: .locations)]
    
    var locationsCategories = [String]()
    
    var tutorialView: SettingsTutorialView?
    let window = UIApplication.shared.keyWindow

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = .white
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = false
        tabBarController?.tabBar.isTranslucent = false
//        hidesBottomBarWhenPushed = true

        setUpCategories()
        showTutorial()
        tableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    func showTutorial() {
        if !UserDefaults.standard.bool(forKey: Constants.Keys.udSettingsTutorialWasShown) {
            tutorialView = SettingsTutorialView(frame: view.frame)
            tutorialView?.delegate = self
            if let tutorialView = tutorialView {
                window?.addSubview(tutorialView)
                UserDefaults.standard.set(true, forKey: Constants.Keys.udSettingsTutorialWasShown)
            }
        }
    }
    
    func setUpCategories() {
        locationsCategories = []
        if let categories = SettingsManager.selectedCategoriesTitles {
            sections[0].categories = categories
        }
        
        if SettingsManager.locationSettings.world {
            locationsCategories.append("Общемировые")
        }
        if SettingsManager.locationSettings.federal {
            locationsCategories.append("Федеральные")
        }
        
        
        if let city = SettingsManager.locationSettings.local {
            
            locationsCategories.append(city)
            
        }
        sections[1].categories = locationsCategories
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingsTableViewCell.self)) as! SettingsTableViewCell
        cell.section = sections[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0,
            let categoriesVC = UIStoryboard.get(flow: .settingsFlow).get(controller: .categoriesVC) as? CategoriesViewController {
            show(categoriesVC, sender: self)
        } else {
            if let locationsVC = UIStoryboard.get(flow: .settingsFlow).get(controller: .locationsVC) as? LocationsViewController {
                show(locationsVC, sender: self)
            }
        }
    }
}

extension SettingsViewController: TutorialDelegate {
    func dismissTutorialView() {
        tutorialView?.removeFromSuperview()
    }
}

enum SettingsType {
    case categories
    case locations
}
