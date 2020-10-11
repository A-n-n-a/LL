//
//  CitiesViewController.swift
//  LifeLines
//
//  Created by Anna on 7/26/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

protocol CitiesViewControllerDelegate {
    func setCity(_ city: String)
}

class CitiesViewController: LLViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: DesignableTextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var backIcon: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelSearchButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var lastCity = UserDefaults.standard.string(forKey: "LastCity")
    var selectedCity: String?
    var cities = SettingsManager.cities
    var filteredCities = [String]() {
        didSet {
            searchTableView.reloadData()
        }
    }
    var editMode = false {
        didSet {
            if oldValue != editMode {
                enableEditMode(editMode)
            }
        }
    }
    
    var searchMode = false {
        didSet {
            showSearchBar(searchMode)
        }
    }
    
    var delegate: CitiesViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        
        tableView.registerCell(for: CityTableViewCell.self)
        tableView.backgroundColor = .white
        searchTableView.registerCell(for: CityTableViewCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func filterCities(query: String) {
        let filteredCities = cities.filter({$0.lowercased().contains(query.lowercased())})
        let unique = Set(filteredCities)
        self.filteredCities = Array(unique)
        searchTableView.isHidden = filteredCities.isEmpty
    }
    
    func enableEditMode(_ enable: Bool) {
        backIcon.isHidden = enable
        backButton.isHidden = enable
        searchIcon.isHidden = enable
        searchButton.isHidden = enable
        
        saveButton.isHidden = !enable
        cancelSearchButton.isHidden = !enable
    }
    
    @IBAction func clearSearchTextField(_ sender: Any) {
        searchTextField.text = ""
    }
    
    @IBAction func saveSearch(_ sender: Any) {
        if let selectedCity = selectedCity {
            delegate?.setCity(selectedCity)
        }
        goBack()
    }
    
    @IBAction func goBackAction(_ sender: Any) {
        goBack()
    }
    
    @IBAction func searchAction(_ sender: Any) {
        searchMode = true
    }
    
    func showSearchBar(_ show: Bool) {
        searchIcon.isHidden = !show
        searchButton.isHidden = !show
        searchView.isHidden = !show
    }
    
    //=========================================================
    // MARK: - Notifications
    //=========================================================
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        if let keyboardSize = keyboardFrame?.cgRectValue {
            let tableInsets = UIEdgeInsets(top: 0, left: 0,
                                           bottom: keyboardSize.height, right: 0)
            searchTableView.contentInset = tableInsets
            searchTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0,
                                                           bottom: keyboardSize.height, right: 0)
            
            
            UIView.animate({
                self.cancelButton.isHidden = false
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate({
            self.cancelButton.isHidden = true
            self.view.layoutIfNeeded()
        })
    }

}

extension CitiesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableView == searchTableView ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchTableView {
            return filteredCities.count
        } else {
            if section == 0 {
                return lastCity == nil ? 0 : 1
            } else {
                return cities.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CityTableViewCell.self)) as! CityTableViewCell
        if tableView == searchTableView {
            let city = filteredCities[indexPath.row]
            cell.isEnable = city == selectedCity
            cell.city = city
            cell.searchMode = true
        } else {
            if indexPath.section == 0, let lastCity = lastCity {
                cell.isLastCity = true
                cell.isEnable = lastCity == selectedCity
                cell.city = lastCity
            } else {
                let city = cities[indexPath.row]
                cell.isEnable = (city == selectedCity && lastCity != selectedCity)
                cell.city = city
            }
        }
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 70 : 52
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let searchMode = tableView == searchTableView
        if searchMode {
            selectedCity = filteredCities[indexPath.row]
        } else {
            if indexPath.section == 0 {
                selectedCity = lastCity
            } else {
                selectedCity = cities[indexPath.row]
            }
        }
        citySelected(indexPath: indexPath, searchMode: searchMode)
    }
}

extension CitiesViewController: CityTableViewCellDelegate {
    func citySelected(indexPath: IndexPath, searchMode: Bool) {
        
        editMode = true
        if searchMode {
            selectedCity = filteredCities[indexPath.row]
            searchTextField.text = selectedCity
            cancelButton.isHidden = true
            view.endEditing(true)
            searchTableView.reloadData()
        } else {
            if indexPath.section == 0 {
                selectedCity = lastCity
            } else {
                selectedCity = cities[indexPath.row]
            }
            tableView.reloadData()
        }
        
    }
}

extension CitiesViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let query = text.replacingCharacters(in: textRange, with: string)
            filterCities(query: query)
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        searchTableView.isHidden = true
        selectedCity = nil
        filteredCities = []
        editMode = false
        searchMode = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.view.endEditing(true)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}


