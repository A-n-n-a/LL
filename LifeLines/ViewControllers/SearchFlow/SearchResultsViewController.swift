//
//  SearchResultsViewController.swift
//  LifeLines
//
//  Created by Anna on 1/20/20.
//  Copyright © 2020 Anna. All rights reserved.
//

import UIKit
import Appodeal

class SearchResultsViewController: LLViewController, LoaderPresenting {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var showConstraint: NSLayoutConstraint!
    @IBOutlet weak var hideConstraint: NSLayoutConstraint!
    @IBOutlet weak var floatingTitle: UILabel!
    @IBOutlet weak var floatingStack: UIStackView!
    @IBOutlet weak var floatingImage: UIImageView!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var scrollToTopView: UIView!
    
    var events = [Event]()
    var query = "" {
        didSet {
            if floatingTitle != nil {
                floatingTitle.text = query
            }
        }
    }
    lazy var loader = LoaderView()
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
        
        titleTextField.text = query
        floatingTitle.text = query
        
        floatingImage.image = #imageLiteral(resourceName: "icSearchTemplate")
        headerImage.image = #imageLiteral(resourceName: "icSearchTemplate")
        floatingImage.tintColor = UIColor.kPurple
        headerImage.tintColor = UIColor.kPurple
        
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
    
    @IBAction func scrollToTop(_ sender: Any) {
        scrollingManually = true
        tableView.setContentOffset(CGPoint.zero, animated: true) //scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.showConstraint.isActive = false
            self.hideConstraint.isActive = true
            self.titleTextField.becomeFirstResponder()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            self.scrollingManually = false
        }
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        goBack()
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
    
    func searchEvents() {
        if currentPage == 1 {
            floatingStack.alpha = 0
            tableView.alpha = 0
            showLoader(text: "Идет поиск...\nПодождите, пожалуйста")
        }
        NetworkManager.getEvents(page: currentPage, query: query) { [weak self]  (events, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error)
                }
                if let events = events {
                    if self?.currentPage == 1 {
                        self?.events = events
                    } else {
                        if events.isEmpty {
                            self?.updateAvailable = false
                        }
                        self?.events.append(contentsOf: events)
                    }
                    self?.tableView.reloadData()
                }
                self?.dismissLoader()
                self?.tableView.alpha = 1
                self?.floatingStack.alpha = 1
            }
        }
    }
    
    @IBAction func toHomePage(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
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
            cell.selectedTag = query
            cell.pictureDelegate = self
            let index = indexForEvent(indexPath: indexPath)
            if index < events.count {
                cell.event = events[indexForEvent(indexPath: indexPath)]
            }
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
            
            let params: [String : Any] = [Constants.Parameters.place : "\(Constants.Parameters.searchResults) open"]
            AnalyticsManager.shared.logEvent(name: Constants.Events.newsViewed, parameters: params)
            
            show(singleEventVC, sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = events.count - 1
        if indexPath.row >= lastElement, updateAvailable {
            currentPage += 1
            searchEvents()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isNavigationTitleHidden = !scrollView.bounds.contains(header.frame)
        animateFloatingTitle(show: isNavigationTitleHidden)
        scrollToTopView.isHidden = !isNavigationTitleHidden
    }
}

extension SearchResultsViewController: EventTableViewCellDelegate, PictureDownloadDelegate {
    func pictureDownloadFailed(indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tagSelected(_ tag: String) {
        
        if let hashTagVC = UIStoryboard.get(flow: .eventsFlow).get(controller: .hashTagEventsVC) as? HashTagEventsViewController {
            hashTagVC.tag = tag
            
            let params: [String : Any] = [Constants.Parameters.place : "\(Constants.Parameters.searchResults) tag"]
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

extension SearchResultsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let searchQuery = text.replacingCharacters(in: textRange, with: string)
            query = searchQuery
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        let searchResult = SearchResult(query: query)
        RealmManager.addOrUpdate(object: searchResult)
        currentPage = 1
        searchEvents()
        return true
    }
}

extension SearchResultsViewController: APDNativeAdQueueDelegate, APDNativeAdPresentationDelegate {
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
