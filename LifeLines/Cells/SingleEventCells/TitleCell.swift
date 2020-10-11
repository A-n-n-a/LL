//
//  TitleCell.swift
//  LifeLines
//
//  Created by Anna on 9/2/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class TitleCell: UITableViewCell {
    
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var sourceLabel: UILabel!
    
    var isFavorite = false {
        didSet {
            updateFavoriteIcon()
        }
    }

    var event: Event? {
        didSet {
            setUpCell()
        }
    }
    
    var delegate: SingleEventCollectionViewCellDelegate?
    
    func setUpCell() {
        guard let event = event else { return }
        
        delegate?.favoriteCell(self)
        
        let date = event.date.changeDateFormat(from: Constants.DateFormats.eventDateFormat, to: Constants.DateFormats.titleFormatFull)
        dateLabel.text = date?.uppercased()
        titleLabel.text = event.title
        isFavorite = event.isFavorite
        sourceLabel.text = event.sourceName
    }
    
    @objc func updateFavoriteIcon() {
        favoriteIcon.image = isFavorite ? #imageLiteral(resourceName: "ic-add-fav") : #imageLiteral(resourceName: "icFavDis")
    }

    @IBAction func addFavorite(_ sender: Any) {
        guard let event = event else { return }
        let eventId = event.id
        if isFavorite {
            isFavorite = false
            delegate?.favoriteAdded(false)
            NetworkManager.deleteFavorite(eventId: eventId) { [weak self] (success, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.isFavorite = true
                        self?.delegate?.favoriteAdded(true)
                        self?.delegate?.showFavoriteError(error: error)
                    }
                    if success {
                        EventsManager.removeFromFavorites(id: eventId)
                        AnalyticsManager.shared.logEvent(name: Constants.Events.newsDeletedInFavorites)
                    }
                }
            }
        } else {
            isFavorite = true
            delegate?.favoriteAdded(true)
            NetworkManager.addFavorite(eventId: eventId) { [weak self] (success, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.isFavorite = false
                        self?.delegate?.favoriteAdded(false)
                        self?.delegate?.showFavoriteError(error: error)
                    }
                    if success {
                        EventsManager.addFavorite(event)
                        AnalyticsManager.shared.logEvent(name: Constants.Events.addToFavorite)
                    }
                }
            }
        }
    }
    @IBAction func openSource(_ sender: Any) {
        if let urlString = event?.url, let url = URL(string: urlString),
            let topVC = UIApplication.topViewController() {
            WebViewManager.shared.openURL(url, from: topVC, title: "")
            AnalyticsManager.shared.logEvent(name: Constants.Events.switchToSource)
        }
    }
}
