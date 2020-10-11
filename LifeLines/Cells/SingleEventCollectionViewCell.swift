//
//  SingleEventCollectionViewCell.swift
//  LifeLines
//
//  Created by Anna on 8/12/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

protocol SingleEventCollectionViewCellDelegate {
    func showFavoriteError(error: Error)
    func favoriteAdded(_ added: Bool)
    func showArticle(id: String)
    func showBottomFavorite(_ show: Bool)
    func favoriteCell(_ cell: TitleCell?)
}

class SingleEventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tableView: UITableView!
    
    var event: Event? {
        didSet {
            setUpCell()
        }
    }
    
    var isFavorite = false {
        didSet {
//            favoriteIcon.image = isFavorite ? #imageLiteral(resourceName: "ic-add-fav") : #imageLiteral(resourceName: "icFavDis")
        }
    }
    
    private var delegate: SingleEventCollectionViewCellDelegate?
    var isScrolling = false
    var firstContentReload = true
    
    func setUpCell() {
        
        tableView.registerCell(for: PictureCell.self)
        tableView.registerCell(for: TitleCell.self)
        tableView.registerCell(for: ContentCell.self)
        tableView.registerCell(for: ArticlesCell.self)
        tableView.registerCell(for: TagsTableViewCell.self)
        tableView.registerCell(for: SourceTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = false
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = true
        
        if event?.events.isEmpty ?? true {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        }
        
        tableView.reloadData()
    }
    
    func setDelegate(_ delegate: SingleEventCollectionViewCellDelegate) {
        self.delegate = delegate
        tableView.reloadData()
    }
}

extension SingleEventCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return event?.events.count == 0 ? 5 : 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PictureCell.self)) as! PictureCell
            cell.indexPath = indexPath
            cell.delegate = self
            cell.event = event
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TitleCell.self)) as! TitleCell
            cell.event = event
            cell.delegate = delegate
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ContentCell.self)) as! ContentCell
            cell.delegate = self
            cell.event = event
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SourceTableViewCell.self)) as! SourceTableViewCell
            cell.event = event
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TagsTableViewCell.self)) as! TagsTableViewCell
            cell.delegate = self
            cell.event = event
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ArticlesCell.self)) as! ArticlesCell
            cell.event = event
            cell.delegate = delegate
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 2:
            return event?.contentHeight ?? UITableView.automaticDimension
        case 3:
            return 50
        case 5:
            return event?.events.count == 0 ? 0 : UITableView.automaticDimension
        default:
            return UITableView.automaticDimension
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 || scrollView.contentOffset.y < 0 {
            guard let titleCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TitleCell,
                let icon = titleCell.favoriteIcon else { return }
            
            let show = scrollView.bounds.contains(icon.frame)
            delegate?.showBottomFavorite(!show)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isScrolling = false
    }
}

extension SingleEventCollectionViewCell: PictureDownloadDelegate {
    func pictureDownloadFailed(indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension SingleEventCollectionViewCell: TagsTableViewCellDelegate {
    func tagSelected(_ tag: String) {
        if let hashTagVC = UIStoryboard.get(flow: .eventsFlow).get(controller: .hashTagEventsVC) as? HashTagEventsViewController {
            hashTagVC.tag = tag
            if let topVC = UIApplication.topViewController() {
                topVC.show(hashTagVC, sender: self)
            }
        }
    }
    
    func placeSelected(_ place: String) {
        if let hashTagVC = UIStoryboard.get(flow: .eventsFlow).get(controller: .hashTagEventsVC) as? HashTagEventsViewController {
            hashTagVC.place = place
            if let topVC = UIApplication.topViewController() {
                topVC.show(hashTagVC, sender: self)
            }
        }
    }
}

extension SingleEventCollectionViewCell: ContentCellDelegate {
    func eventContentLoaded(height: CGFloat, eventId: String) {
        if event?.id == eventId, event?.contentHeight == nil {
            event?.contentHeight = height
            tableView.reloadData()
            firstContentReload = false
        }
    }
}
