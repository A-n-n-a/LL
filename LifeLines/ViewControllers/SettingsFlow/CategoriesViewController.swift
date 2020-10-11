//
//  CategoriesViewController.swift
//  LifeLines
//
//  Created by Anna on 7/18/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class CategoriesViewController: LLViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    
    var categories = [Category]() {
        didSet {
            //copy to be able change values before saving to DB
            categoriesCopy = categories.map({ (category) -> Category in
                return Category(title: category.title, isEnable: category.isEnable)
            })
            tableView.reloadData()
        }
    }
    
    var allTopics = Category(title: "Все темы", isEnable: true)
    var categoriesCopy = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar(title: "Темы событий")
        navigationController?.navigationBar.barStyle = .black
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = true
        tabBarController?.tabBar.isTranslucent = true
        
        if let categories = SettingsManager.categories, !categories.isEmpty {
            self.categories = Array(categories)
        } else {
            getCategories()
        }
        
        allTopics.isEnable = allCategoriesSelected()
        
        tableView.registerCell(for: SwitchTableViewCell.self)
        tableView.backgroundColor = .white
    }

    func getCategories() {
        NetworkManager.getSettingsCategories { [weak self] (categories, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error)
                }
                if let categories = categories {
                    self?.categories = categories
                    RealmManager.addOrUpdate(objects: categories)
                }
            }
        }
    }
    
    func allCategoriesSelected() -> Bool {
        for category in categoriesCopy {
            if !category.isEnable {
                return false
            }
        }
        return true
    }
    
    func allCategoriesDeselected() -> Bool {
        for category in categoriesCopy {
            if category.isEnable {
                return false
            }
        }
        return true
    }
    
    override func goBack() {
        if allCategoriesDeselected() {
            self.showError("Пожалуйста, выберите хотя бы одну интересующую Вас тему")
        } else {
            super.goBack()
        }
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        var errorMessage: String?
        let params = categoriesCopy.reduce([String: Any]()) { (dict, category) -> [String: Any] in
            var newDict = dict
            newDict[category.title] = category.isEnable
            return newDict
        }
        AnalyticsManager.shared.logEventOneSignal(name: Constants.Events.topicSelected, properties: params)
        let updateGroup = DispatchGroup()
        
        DispatchQueue.concurrentPerform(iterations: categoriesCopy.count) { counterIndex in
            let index = Int(counterIndex)
            let category = categoriesCopy[index]
            
            updateGroup.enter()
            
            NetworkManager.saveSettingsCategories(category: category) { (success, error) in
                DispatchQueue.main.async {
                    if success {
//                        self?.addedBills.append(bill)
                    } else if let error = error {
                        errorMessage = error.localizedDescription
                    }
                    updateGroup.leave()
                }
            }
        }
        updateGroup.notify(queue: DispatchQueue.main) {
            if let errorMessage = errorMessage {
                self.showError(errorMessage as AnyObject)
            } else {
                RealmManager.addOrUpdate(objects: self.categoriesCopy)
                if let navVC = self.tabBarController?.viewControllers?.first as? UINavigationController,
                    let eventsVC = navVC.viewControllers.first as? EventsViewController {
                    eventsVC.needsToUpdate = true
                    self.tabBarController?.selectedIndex = 0
                    self.tabBarController?.tabBar.isHidden = false
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
}

extension CategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : categoriesCopy.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SwitchTableViewCell.self)) as! SwitchTableViewCell
        cell.category = indexPath.section == 0 ? allTopics : categoriesCopy[indexPath.row]
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
}

extension CategoriesViewController: SwitchTableViewCellDelegate {
    func switchValueChanged(indexPath: IndexPath, isEnable: Bool) {
        if indexPath.section == 0 {
            if isEnable {
                allTopics.isEnable = true
                categoriesCopy.forEach({ $0.isEnable = true })
                saveButton.isHidden = false
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
            } else {
                allTopics.isEnable = false
                categoriesCopy.forEach({ $0.isEnable = false })
                saveButton.isHidden = true
                tableView.contentInset = UIEdgeInsets.zero
            }
            tableView.reloadData()
        } else {
            categoriesCopy[indexPath.row].isEnable = isEnable
            allTopics.isEnable = allCategoriesSelected()
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            saveButton.isHidden = false
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        }
        
    }
}
