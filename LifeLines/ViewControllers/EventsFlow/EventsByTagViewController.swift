//
//  EventsByTagViewController.swift
//  LifeLines
//
//  Created by Anna on 10/1/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit
import Appodeal

class EventsByTagViewController: LLViewController, LoaderPresenting {
    
    @IBOutlet weak var toolBar: UIView!
    @IBOutlet weak var toolbarHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tagsSubtitle: UILabel!
    @IBOutlet weak var scrollToTopView: UIView!
    
    var tags = [String]()
    var events = [Event]() {
        didSet {
            tableView.backgroundView?.alpha = events.isEmpty ? 1 : 0
            tableView.reloadData()
        }
    }
    lazy var loader = LoaderView()
    let searchView = SearchBarView(frame: UIScreen.main.bounds)
    private lazy var backgroundView = TableBackgroundView()
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

        tagsSubtitle.text = "Явления по #: \(tags.joined(separator: ", "))"
        
        backgroundView.set(image: #imageLiteral(resourceName: "icSearch"))
        backgroundView.setTitleText(NSLocalizedString("Ничего не найдено", comment: ""))
        
        tableView.backgroundView = backgroundView
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.registerCell(for: EventTableViewCell.self)
        tableView.registerCell(for: NativeAdTableViewCell.self)
        tableView.estimatedRowHeight = 140
        
        if tags.count > 0 {
            searchEventsWith(tags: tags)
        }
        
        toolbarHeight.constant = UIDevice.current.isFrameless() ? 92 : 72
        
        searchView.delegate = self
        searchView.tags = tags
        searchView.alpha = 0
        view.addSubview(searchView)
        
        nativeAdQueue.delegate = self
        nativeAdQueue.loadAd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
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
        return .lightContent
    }

    func searchEventsWith(tags: [String]) {
        if currentPage == 1 {
            tableView.alpha = 0
            showLoader()
        }
       NetworkManager.getEvents(hashtags: tags, page: currentPage) { [weak self]  (events, error) in
           DispatchQueue.main.async {
               if let error = error {
                   self?.showError(error)
               }
               if let events = events {
                if events.isEmpty {
                    self?.updateAvailable = false
                }
                   self?.events.append(contentsOf: events)
               }
               self?.dismissLoader()
               self?.tableView.alpha = 1
           }
       }
   }
    
    @IBAction func searchAction(_ sender: Any) {
        
        searchView.alpha = 1
        searchView.setFirstResponder()
    }
    
    @IBAction func backAction(_ sender: Any) {
        goBack()
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

extension EventsByTagViewController: UITableViewDelegate, UITableViewDataSource {
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
            cell.event = events[indexForEvent(indexPath: indexPath)]
            cell.delegate = self
            cell.urlDelegate = self
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !adIndexes.filter({$0 == indexPath.row}).isEmpty {
            return nativeArray.isEmpty ? 0 : Constants.Height.nativeAdHeight
        }
        return  UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let singleEventVC = UIStoryboard.get(flow: .eventsFlow).get(controller: .singleEventVC) as? SingleEventViewController {
            let event = events[indexForEvent(indexPath: indexPath)]
            singleEventVC.eventId = event.id
            singleEventVC.tags = Array(event.tags)
            show(singleEventVC, sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = events.count - 1
        if indexPath.row >= lastElement, updateAvailable {
            currentPage += 1
            searchEventsWith(tags: tags)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let cell = tableView.cellForRow(at: IndexPath.zero()) else { return }
        let isNavigationTitleHidden = !scrollView.bounds.contains(cell.frame)
        scrollToTopView.isHidden = !isNavigationTitleHidden
    }
}

extension EventsByTagViewController: EventTableViewCellDelegate, PictureDownloadDelegate {
    func pictureDownloadFailed(indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func categorySelected(_ category: String) {
        if let hashTagVC = UIStoryboard.get(flow: .eventsFlow).get(controller: .hashTagEventsVC) as? HashTagEventsViewController {
            hashTagVC.category = category
            show(hashTagVC, sender: self)
        }
    }
    
    func tagSelected(_ tag: String) {
        if let hashTagVC = UIStoryboard.get(flow: .eventsFlow).get(controller: .hashTagEventsVC) as? HashTagEventsViewController {
            hashTagVC.tag = tag
            
            let params: [String : Any] = [Constants.Parameters.place : "\(Constants.Parameters.tagSearchResults) tag"]
            AnalyticsManager.shared.logEvent(name: Constants.Events.pressedTag, parameters: params)
            
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

extension EventsByTagViewController: OpenURLDelegate {
    func open(url: URL) {
        WebViewManager.shared.openURL(url, from: self, title: "")
        AnalyticsManager.shared.logEvent(name: Constants.Events.switchToSource)
    }
}

extension EventsByTagViewController: SearchBarViewDelegate {
    func searchWithTags(_ tags: [String]) {
        view.endEditing(true)
        tagsSubtitle.text = "Явления по #: \(tags.joined(separator: ", "))"
        searchEventsWith(tags: tags)
        searchView.alpha = 0
    }
    
    func cancelSearch() {
        searchView.alpha = 0
    }
}

extension EventsByTagViewController: APDNativeAdQueueDelegate, APDNativeAdPresentationDelegate {
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
