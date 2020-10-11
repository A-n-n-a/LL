//
//  LocationsViewController.swift
//  LifeLines
//
//  Created by Anna on 7/21/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class LocationsViewController: LLViewController {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var localTitleLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var worldSwitch: UISwitch!
    @IBOutlet weak var federalSwitch: UISwitch!
    @IBOutlet weak var localSwitch: UISwitch!
    @IBOutlet weak var localView: UIView!
    
    var tempSettings = SettingsLocations() {
        didSet {
            updateSettingsViews()
        }
    }
    
    lazy var operationQueue: OperationQueue = {
      var queue = OperationQueue()
      queue.name = "Save settings queue"
      queue.maxConcurrentOperationCount = 1
      return queue
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar(title: "География событий")
        navigationController?.navigationBar.barStyle = .black
        
        tabBarController?.tabBar.isHidden = true
        tabBarController?.tabBar.isTranslucent = true
        
        tempSettings = SettingsManager.locationSettings.copy()
        
        setUpLocalView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setUpLocalView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(goToCitiesList))
        localView.addGestureRecognizer(gesture)
    }
    
    func updateSettingsViews() {
        updateWorldView()
        updateFederalView()
        updateLocalView()
    }
    
    func updateWorldView() {
        worldSwitch.setOn(tempSettings.world, animated: true)
    }
    
    func updateFederalView() {
        federalSwitch.setOn(tempSettings.federal, animated: true)
    }
    
    func updateLocalView() {
        let cityName = tempSettings.local ?? SettingsManager.lastCity
        if let city = cityName {
            localTitleLabel.isHidden = false
            localTitleLabel.text = "Локальные"
            cityLabel.text = city
        } else {
            localTitleLabel.isHidden = true
            cityLabel.text = "Локальные"
        }
        
        var cityEnable = false
        if tempSettings.local != nil {
            cityEnable = true
        } else {
            if SettingsManager.lastCity != nil {
                cityLabel.text = SettingsManager.lastCity
            }
        }
        
        localSwitch.setOn(cityEnable, animated: true)
        cityLabel.textColor = cityEnable ? UIColor.black : UIColor.kLightPurple
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        
        activityIndicator.startAnimating()
        
        let params: [String: Any] = [Constants.Parameters.world : tempSettings.world,
                                     Constants.Parameters.federal : tempSettings.federal,
                                     Constants.Parameters.local : tempSettings.local != nil]
        AnalyticsManager.shared.logEventOneSignal(name: Constants.Events.locationSelected, properties: params)
        
        NetworkManager.saveLocations(world: tempSettings.world, federal: tempSettings.federal, local: tempSettings.local) { [weak self]  (success, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.activityIndicator.stopAnimating()
                    self?.showError(error)
                }
                if success {
                    self?.getSettingsLocations()
                    self?.goToPulse()
                }
            }
        }
        
//        if SettingsManager.locationSettings.world != tempSettings.world {
//            operationQueue.addOperation {
//                self.saveWorld()
//            }
//        }
//        if SettingsManager.locationSettings.federal != tempSettings.federal {
//            operationQueue.addOperation {
//                self.saveFederal()
//            }
//        }
//        if SettingsManager.locationSettings.local != tempSettings.local {
//            operationQueue.addOperation {
//                self.saveLocal()
//            }
//        }
        
//        operationQueue.waitUntilAllOperationsAreFinished()
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
//        }
    }
    
    func saveWorld() {
        NetworkManager.saveLocation(name: "WORLD", value: tempSettings.world) { [weak self] (success, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.activityIndicator.stopAnimating()
                    self?.showError(error)
                }
            }
        }
    }
    
    func saveFederal() {
        NetworkManager.saveLocation(name: "FEDERAL", value: tempSettings.federal) { [weak self] (success, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.activityIndicator.stopAnimating()
                    self?.showError(error)
                }
            }
        }
    }
    
    func saveLocal() {
        NetworkManager.saveLocalLocation(city: tempSettings.local) { [weak self] (success, error) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                if let error = error {
                    self?.showError(error)
                }
                if success {
                    if let city = self?.tempSettings.local {
                        SettingsManager.lastCity = city
                    }
                }
            }
        }
    }
    
    func goToPulse() {
        if let navVC = self.tabBarController?.viewControllers?.first as? UINavigationController,
            let eventsVC = navVC.viewControllers.first as? EventsViewController {
            eventsVC.needsToUpdate = true
            self.tabBarController?.selectedIndex = 0
            self.tabBarController?.tabBar.isHidden = false
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc func goToCitiesList() {
        if let citiesVC = UIStoryboard.get(flow: .settingsFlow).get(controller: .citiesVC) as? CitiesViewController {
            citiesVC.selectedCity = tempSettings.local
            citiesVC.delegate = self
            show(citiesVC, sender: self)
        }
    }
    
    @IBAction func switchWorld(_ sender: Any) {
        worldSwitch.setOn(!worldSwitch.isOn, animated: true)
        if !worldSwitch.isOn, !federalSwitch.isOn, !localSwitch.isOn {
            worldSwitch.setOn(true, animated: true)
        } else {
            tempSettings.world = worldSwitch.isOn
            saveButton.isHidden = false
        }
    }

    @IBAction func switchFederal(_ sender: Any) {
        federalSwitch.setOn(!federalSwitch.isOn, animated: true)
        if !federalSwitch.isOn, !worldSwitch.isOn, !localSwitch.isOn {
            federalSwitch.setOn(true, animated: true)
        } else {
            tempSettings.federal = federalSwitch.isOn
            saveButton.isHidden = false
        }
    }
    
    @IBAction func selectCity(_ sender: Any) {
        goToCitiesList()
    }
    @IBAction func switchLocal(_ sender: Any) {
        localSwitch.setOn(!localSwitch.isOn, animated: true)
        if !localSwitch.isOn, !federalSwitch.isOn, !worldSwitch.isOn {
            localSwitch.setOn(true, animated: true)
        } else {
            saveButton.isHidden = false
        }
        
        if localSwitch.isOn {
            if tempSettings.local == nil, SettingsManager.lastCity == nil {
                localSwitch.setOn(false, animated: true)
                goToCitiesList()
            } else {
                tempSettings.local = tempSettings.local ?? SettingsManager.lastCity
            }
        } else {
            tempSettings.local = nil
        }
    }
}

extension LocationsViewController: CitiesViewControllerDelegate {
    func setCity(_ city: String) {
        saveButton.isHidden = false
        tempSettings.local = city
        updateSettingsViews()
    }
}
