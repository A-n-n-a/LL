//
//  LLViewController.swift
//  LifeLines
//
//  Created by Anna on 7/7/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit
import Appodeal

class LLViewController: UIViewController {
    
    let window = UIApplication.shared.keyWindow
    let blackView = UIView()
    
    let nativePeriod = 6
    lazy var nativeAdQueue : APDNativeAdQueue = {
        return APDNativeAdQueue(sdk: nil,
                                settings: self.nativeAdSettings,
                                delegate: nil,
                                autocache: true)
    }()
    
    var nativeAdSettings: APDNativeAdSettings! {
        get {
            let instance = APDNativeAdSettings()
            instance.adViewClass = NativeView.self
            instance.type = .video
            instance.autocacheMask = [.media, .icon]
            return instance;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
    }
    
    @objc func handleDismiss() {
        
    }
    
    func setNavigationBar(title: String? = nil, /*subtitle: String? = nil,*/ leftButtonTitle: String? = nil) {
        
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: self.view.frame.width, height: 72)
        self.navigationItem.setHidesBackButton(true, animated:true)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.navigationController?.navigationBar.barTintColor = UIColor.kPurple
        
        // set left title button
        let goBackButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic-back"),  style: .plain, target: self, action: #selector(goBack))
        self.navigationItem.leftBarButtonItems = [goBackButton]
        
        //title view
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 170, height: 35))
        titleView.backgroundColor = UIColor.clear
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 7, width: 170, height: 18))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.text = title
        titleView.addSubview(titleLabel)
        self.navigationItem.titleView = titleView
    }
    
    func setWhiteNavigationBar() {
        
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: self.view.frame.width, height: 72)
        self.navigationItem.setHidesBackButton(true, animated:true)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        
        // set left title button
        let goBackButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic-back-purple"),  style: .plain, target: self, action: #selector(goBack))
        
        self.navigationItem.leftBarButtonItems = [goBackButton]
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func search() {
        
    }
    
    @objc func share() {
        
    }
    
    func showError<T>(_ error: T) {
        var title = ""
        if let err = error as? LLError {
            title = err.message
        } else if let err = error as? Error {
            title = err.localizedDescription
        } else if let err = error as? String {
            title = err
        }
        let myAlert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func showAlert(title: String?, message: String?, actions: [UIAlertAction]) {
        let myAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            myAlert.addAction(action)
        }
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func showActionSheet(actions: [UIAlertAction]) {
        let myAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for action in actions {
            myAlert.addAction(action)
        }
        myAlert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func drawShadow(for view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        view.layer.shadowOpacity = 0.16
        view.layer.shadowRadius = 10
    }
    
    func getSettingsLocations() {
        NetworkManager.getSettingsLocations { [weak self] (locations, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error)
                }
                if let locations = locations {
                    SettingsManager.locationSettings = locations
                }
            }
        }
    }
    
    func cellsCount(events: [Event]) -> Int {
        let pages = events.count / 20
        let adsCount = pages * 4
        let total = events.count + adsCount
        return total
    }
    
    func indexForEvent(indexPath: IndexPath) -> Int {
        guard indexPath.row > 4 else { return indexPath.row }
        let adsCount = indexPath.row / nativePeriod
        return indexPath.row - adsCount
    }
}
