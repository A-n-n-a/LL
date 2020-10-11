//
//  HashTagEventsViewController.swift
//  LifeLines
//
//  Created by Anna on 7/30/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit
import Appodeal

class HashTagEventsViewController: LLViewController, LoaderPresenting {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var showConstraint: NSLayoutConstraint!
    @IBOutlet weak var hideConstraint: NSLayoutConstraint!
    @IBOutlet weak var floatingTitle: UILabel!
    @IBOutlet weak var floatingStack: UIStackView!
    @IBOutlet weak var floatingImage: UIImageView!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var hashtagLabel: UILabel!
    @IBOutlet weak var floatingHashtagLabel: UILabel!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var floatingImageContainer: UIView!
    @IBOutlet weak var scrollToTopView: UIView!
    
    lazy var loader = LoaderView()
    var tag: String?
    var category: String?
    var place: String?
    var events = [Event]() {
        didSet {
            tableView.reloadData()
        }
    }
    var scrollingManually = false
    var currentPage = 1
    var nativeArray: [APDNativeAd] = []
    var nextIndex = 5 {
        didSet {
            adIndexes.append(nextIndex)
        }
    }
    var adIndexes = [5]
    var updateAvailable = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerCell(for: EventTableViewCell.self)
        tableView.registerCell(for: NativeAdTableViewCell.self)
        tableView.backgroundColor = .white
        
        tabBarController?.tabBar.isHidden = true
        tabBarController?.tabBar.isTranslucent = true
        
        var image: UIImage?
        if let tag = tag {
            floatingTitle.text = tag.nounCapitalized()
            titleTextField.text = tag.nounCapitalized()
            image = #imageLiteral(resourceName: "icSearchTemplate")
            getEventsBy(tag: tag)
            imageContainer.isHidden = true
            floatingImageContainer.isHidden = true
            hashtagLabel.isHidden = false
            floatingHashtagLabel.isHidden = false
        } else if let category = category {
            floatingTitle.text = category.nounCapitalized()
            titleTextField.text = category.nounCapitalized()
            image = #imageLiteral(resourceName: "ic-add-fav-1")
            getEventsBy(category: category)
            imageContainer.isHidden = false
            floatingImageContainer.isHidden = false
            hashtagLabel.isHidden = true
            floatingHashtagLabel.isHidden = true
        } else if let place = place {
            floatingTitle.text = place.nounCapitalized()
            titleTextField.text = place.nounCapitalized()
            image = #imageLiteral(resourceName: "ic-add-fav-2")
            getEventsBy(place: place)
            imageContainer.isHidden = false
            floatingImageContainer.isHidden = false
            hashtagLabel.isHidden = true
            floatingHashtagLabel.isHidden = true
        }
        floatingImage.image = image
        headerImage.image = image
        
        nativeAdQueue.delegate = self
        nativeAdQueue.loadAd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setWhiteNavigationBar()
    }
    
    func presentNative(onView view: UIView,
    fromIndex index: NSIndexPath) {
        let nativeAd = nativeArray.first
        if let nativeAd = nativeAd {
            nativeAd.delegate = self
            do {
                let adView = try nativeAd.getViewForPlacement("default", withRootViewController: self)
                adView.frame = view.bounds
                view.addSubview(adView)
            } catch {
                print("error")
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        goBack()
    }
    
    func getEventsBy(tag: String) {
        
        if currentPage == 1 {
            showLoader()
        }
        NetworkManager.getEvents(hashtag: tag, page: currentPage) { [weak self] (events, error) in
            DispatchQueue.main.async {
                self?.dismissLoader()
                if let error = error {
                    self?.showError(error)
                }
                if let events = events {
                    if events.isEmpty {
                        self?.updateAvailable = false
                    }
                    self?.events.append(contentsOf: events)
                }
            }
        }
    }
    
    func getEventsBy(category: String) {
        
        showLoader()
        NetworkManager.getEvents(category: category) { [weak self] (events, error) in
            DispatchQueue.main.async {
                self?.dismissLoader()
                if let error = error {
                    self?.showError(error)
                }
                if let events = events {
                    self?.events = events
                }
            }
        }
    }
    
    func getEventsBy(place: String) {
        
        showLoader()
        NetworkManager.getEvents(place: place) { [weak self] (events, error) in
            DispatchQueue.main.async {
                self?.dismissLoader()
                if let error = error {
                    self?.showError(error)
                }
                if let events = events {
                    self?.events = events
                }
            }
        }
    }
    
    private func animateFloatingTitle(show: Bool) {
        
        guard !scrollingManually else { return }
        
        view.layoutIfNeeded()
        
        if show {
            NSLayoutConstraint.deactivate([hideConstraint])
            NSLayoutConstraint.activate([showConstraint])
        } else {
            NSLayoutConstraint.deactivate([showConstraint])
            NSLayoutConstraint.activate([hideConstraint])
        }
        
        UIView.animate(withDecision: true,
                       animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func scrollToTop(_ sender: Any) {
        scrollToTop()
    }
    
    @IBAction func toHomePage(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    func scrollToTop() {
        tableView.reloadData()
        if events.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}

extension HashTagEventsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellsCount(events: events)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !adIndexes.filter({$0 == indexPath.row}).isEmpty {
            nextIndex += nativePeriod
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NativeAdTableViewCell.self)) as! NativeAdTableViewCell
            presentNative(onView: cell.contentView, fromIndex: indexPath as NSIndexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventTableViewCell.self)) as! EventTableViewCell
            cell.indexPath = indexPath
            cell.pictureDelegate = self
            cell.selectedTag = tag
            cell.selectedCategory = category
            cell.selectedPlace = place
            cell.event = events[indexForEvent(indexPath: indexPath)]
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !adIndexes.filter({$0 == indexPath.row}).isEmpty {
            return nativeArray.isEmpty ? 0 : Constants.Height.nativeAdHeight
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let singleEventVC = UIStoryboard.get(flow: .eventsFlow).get(controller: .singleEventVC) as? SingleEventViewController {
            let event = events[indexForEvent(indexPath: indexPath)]
            singleEventVC.eventId = event.id
            singleEventVC.tags = Array(event.tags)
            
            let params: [String : Any] = [Constants.Parameters.place : "\(Constants.Parameters.tagSearchResults) open"]
            AnalyticsManager.shared.logEvent(name: Constants.Events.newsViewed, parameters: params)
            
            show(singleEventVC, sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = events.count - 1
        if indexPath.row >= lastElement, updateAvailable {
            currentPage += 1
            if let tag = tag {
                getEventsBy(tag: tag)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isNavigationTitleHidden = !scrollView.bounds.contains(header.frame)
        animateFloatingTitle(show: isNavigationTitleHidden)
        scrollToTopView.isHidden = !isNavigationTitleHidden
    }
}

extension HashTagEventsViewController: EventTableViewCellDelegate, PictureDownloadDelegate {
    func pictureDownloadFailed(indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tagSelected(_ tag: String) {
        
        if let hashTagVC = UIStoryboard.get(flow: .eventsFlow).get(controller: .hashTagEventsVC) as? HashTagEventsViewController {
            hashTagVC.tag = tag
            
            let params: [String : Any] = [Constants.Parameters.place : "\(Constants.Parameters.tagSearchResults) tag"]
            AnalyticsManager.shared.logEvent(name: Constants.Events.pressedTag, parameters: params)
            
            show(hashTagVC, sender: self)
        }
        
    }
    
    func categorySelected(_ category: String) {
        
        if let hashTagVC = UIStoryboard.get(flow: .eventsFlow).get(controller: .hashTagEventsVC) as? HashTagEventsViewController {
            hashTagVC.category = category
            show(hashTagVC, sender: self)
        }
    }
    
    func placeSelected(_ place: String) {
        if let hashTagVC = UIStoryboard.get(flow: .eventsFlow).get(controller: .hashTagEventsVC) as? HashTagEventsViewController {
            hashTagVC.place = place
            show(hashTagVC, sender: self)
        }
    }
}

extension HashTagEventsViewController: APDNativeAdQueueDelegate, APDNativeAdPresentationDelegate {
    func adQueueAdIsAvailable(_ adQueue: APDNativeAdQueue, ofCount count: UInt) {
        if nativeArray.count > 0 {
            return
        } else {
            nativeArray.append(contentsOf: adQueue.getNativeAds(ofCount: 1))
            _ = nativeArray.map{( $0.delegate = self )}
        }
        tableView.reloadData()
    }
    
    func adQueue(_ adQueue: APDNativeAdQueue, failedWithError error: Error) {
        print("ERROR: ", error)
        print("")
    }
}
