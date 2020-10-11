//
//  FavoritesViewController.swift
//  LifeLines
//
//  Created by Anna on 7/6/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class FavoritesViewController: LLViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showConstraint: NSLayoutConstraint!
    @IBOutlet weak var hideConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    private lazy var backgroundView = TableBackgroundView()
    
    var favorites = [Event]() {
        didSet {
            tableView.backgroundView?.alpha = favorites.isEmpty ? 1 : 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundView.set(image: #imageLiteral(resourceName: "icFavPrev"))
        backgroundView.setTitleText(NSLocalizedString("Пока ничего нет", comment: ""))
        backgroundView.setSubtitleText(NSLocalizedString("Сохраняйте понравившиеся явления, чтобы прочитать их потом.", comment: ""))
        
        tableView.backgroundView = backgroundView
        tableView.backgroundColor = .white
        tableView.registerCell(for: FavoritesTableViewCell.self)
        
        favorites = EventsManager.favorites
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = false
        tabBarController?.tabBar.isTranslucent = false
        if EventsManager.favoritesNeedUpdate {
            favorites = EventsManager.favorites
            tableView.reloadData()
            EventsManager.favoritesNeedUpdate = false
        }
        
        AnalyticsManager.shared.logEvent(name: Constants.Events.favoritesAreViewed)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    func deleteFavorite(at indexPath: IndexPath) {
        let eventId = favorites[indexPath.row].id
        NetworkManager.deleteFavorite(eventId: eventId) { [weak self] (success, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error)
                }
                if success {
                    EventsManager.removeFromFavorites(id: eventId)
                    self?.favorites.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .bottom)
                    AnalyticsManager.shared.logEvent(name: Constants.Events.newsDeletedInFavorites)
                }
            }
        }
    }
    
    private func animateFloatingTitle(show: Bool) {
        view.layoutIfNeeded()
        
        if show {
            hideConstraint.isActive = false
            showConstraint.isActive = true
        } else {
            showConstraint.isActive = false
            hideConstraint.isActive = true
        }
        
        UIView.animate(withDecision: true,
                       animations: {
            self.view.layoutIfNeeded()
        })
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FavoritesTableViewCell.self)) as! FavoritesTableViewCell
        cell.event = favorites[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let singleEventVC = UIStoryboard.get(flow: .eventsFlow).get(controller: .singleEventVC) as? SingleEventViewController {
            let event = favorites[indexPath.row]
            singleEventVC.eventId = event.id
            singleEventVC.tags = Array(event.tags)
            
            let params: [String : Any] = [Constants.Parameters.place : "\(Constants.Parameters.favorites) open"]
            AnalyticsManager.shared.logEvent(name: Constants.Events.newsViewed, parameters: params)
            
            show(singleEventVC, sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteFavorite(at: indexPath)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isNavigationTitleHidden = !scrollView.bounds.contains(titleLabel.frame)
        animateFloatingTitle(show: isNavigationTitleHidden)
    }
}

extension FavoritesViewController: OpenURLDelegate {
    func open(url: URL) {
        WebViewManager.shared.openURL(url, from: self, title: "")
        AnalyticsManager.shared.logEvent(name: Constants.Events.switchToSource)
    }
}
