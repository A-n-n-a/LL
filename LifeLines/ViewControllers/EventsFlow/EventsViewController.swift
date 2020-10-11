//
//  ViewController.swift
//  LifeLines
//
//  Created by Anna on 7/6/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit
import Appodeal

class EventsViewController: LLViewController, LoaderPresenting {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var updateIcon: UIImageView!
    @IBOutlet weak var scrollToTopView: UIView!
    @IBOutlet weak var showConstraint: NSLayoutConstraint!
    @IBOutlet weak var hideConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateFloatingLabel: UILabel!
    
    var events = [Event]() {
        didSet {
            EventsManager.events = events
            tableView.reloadData()
            backgroundView.alpha = events.isEmpty ? 1 : 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                self.showTutorial()
            }
        }
    }
    
    var needsToUpdate = Bool() {
        didSet {
            events = []
        }
    }
    lazy var loader = LoaderView()
    var hashtags: [String]?
    
    var currentPage = 1
    var isFetchInProgress = false
    var firstUpdate = true
    private lazy var backgroundView = TableBackgroundView()
    var tutorialView: PulseTutorialView?
    var nativeArray: [APDNativeAd] = []
    var nextIndex = 5 {
        didSet {
            adIndexes.append(nextIndex)
        }
    }
    var adIndexes = [5]
    var updateAvailable = true
    var topEventIndex = 0 {
        didSet {
            if oldValue != topEventIndex {
                let event = events[topEventIndex]
                dateFloatingLabel.text = event.date.changeDateFormat(from: Constants.DateFormats.eventDateFormat, to: Constants.DateFormats.titleFormat)?.capitalizingFirstLetter()
            }
        }
    }
    
    private let adCache: NSMapTable <NSIndexPath, APDNativeAd> = NSMapTable.strongToStrongObjects()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        backgroundView.set(image: #imageLiteral(resourceName: "icRef"), template: true)
        backgroundView.setTitleText(NSLocalizedString("Данные обновляются, попробуйте позже", comment: ""))
        tableView.backgroundView = backgroundView
        tableView.estimatedRowHeight = 140
        tableView.registerCell(for: EventTableViewCell.self)
        tableView.registerCell(for: NativeAdTableViewCell.self)
        
        let persistedEvents = EventsManager.events
        let sortedEvents = persistedEvents.sorted(by: {
            if let firstDate = $0.date.toDateWith(format: Constants.DateFormats.eventDateFormat), let secondDate = $1.date.toDateWith(format: Constants.DateFormats.eventDateFormat) {
                return firstDate > secondDate
            }
            return $0.date > $1.date
        })
        self.events = sortedEvents
        
        let currentDate = Date().toString(format: Constants.DateFormats.titleFormat)
        dateLabel.text = currentDate.uppercased()
        dateFloatingLabel.text = currentDate.capitalizingFirstLetter()
        
        nativeAdQueue.delegate = self
        nativeAdQueue.loadAd()
    }

    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        tabBarController?.tabBar.isTranslucent = false
        
        if needsToUpdate {
            updateEvents()
            needsToUpdate = false
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    func showTutorial() {
        if !UserDefaults.standard.bool(forKey: Constants.Keys.udPulseTutorialWasShown) {
            tutorialView = PulseTutorialView(frame: view.frame)
            tutorialView?.events = events
            tutorialView?.delegate = self
            if let tutorialView = tutorialView {
                window?.addSubview(tutorialView)
                UserDefaults.standard.set(true, forKey: Constants.Keys.udPulseTutorialWasShown)
            }
        }
    }
    
    func getEvents() {
        NetworkManager.getEvents() { [weak self]  (events, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error)
                }
                if let events = events {
                    self?.events = events
                }
            }
        }
    }
    
    func updateEvents(hashtags: [String]? = nil, page: Int? = nil) {
        if page == nil {
            tableView.alpha = 0
            showLoader()
        } else {
            guard !isFetchInProgress else { return }
        }
        isFetchInProgress = true
        NetworkManager.getEvents(hashtags: hashtags, page: page) { [weak self]  (events, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error)
                }
                if let events = events {
                    self?.isFetchInProgress = false
                    if events.isEmpty {
                        self?.updateAvailable = false
                    }
                    self?.events.append(contentsOf: events)
                }
                if page == nil {
                    self?.dismissLoader()
                    self?.tableView.alpha = 1
                }
            }
        }
    }
    
    func showNewEvents(with newIndexPathsToReload: [IndexPath]?) {
        
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            tableView.reloadData()
            return
        }
        tableView.beginUpdates()
        tableView.reloadRows(at: newIndexPathsToReload, with: .automatic)
        tableView.endUpdates()
    }
    
    private func calculateIndexPathsToReload(from newEvents: [Event]) -> [IndexPath] {
        let startIndex = events.count - newEvents.count
        let endIndex = startIndex + newEvents.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    private func animateFloatingTitle(show: Bool) {
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
                        self.dateLabel.alpha = show ? 0 : 1
                        self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func updateFeed(_ sender: Any) {
        updateIcon.rotate()
        updateEvents()
        scrollToTop()
        AnalyticsManager.shared.logEvent(name: Constants.Events.pageUpdate)
    }
    @IBAction func scrollToTop(_ sender: Any) {
        scrollToTop()
    }
    
    func scrollToTop() {
        tableView.reloadData()
        if events.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
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
}

extension EventsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : cellsCount(events: events)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeaderCell.self)) as! HeaderCell
            cell.selectionStyle = .none
            cell.backgroundColor = .white
            cell.contentView.backgroundColor = .white
            return cell
        }
        
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
        if indexPath.section == 0 {
            return 60
        }
        if !adIndexes.filter({$0 == indexPath.row}).isEmpty {
            return nativeArray.isEmpty ? 0 : Constants.Height.nativeAdHeight
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        if let singleEventVC = UIStoryboard.get(flow: .eventsFlow).get(controller: .singleEventVC) as? SingleEventViewController {
            let event = events[indexForEvent(indexPath: indexPath)]
            singleEventVC.eventId = event.id
            singleEventVC.tags = Array(event.tags)
            singleEventVC.delegate = self
            
            let params: [String : Any] = [Constants.Parameters.place : "\(Constants.Parameters.pulse) open"]
            AnalyticsManager.shared.logEvent(name: Constants.Events.newsViewed, parameters: params)
            
            show(singleEventVC, sender: self)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let indexPath = tableView.indexPathsForVisibleRows?.first, indexPath.section > 0 {
            topEventIndex = indexForEvent(indexPath: indexPath)
        }
        
        if let cell = tableView.cellForRow(at: IndexPath.zero()) {
            let isNavigationTitleHidden = !scrollView.bounds.contains(cell.frame)
            scrollToTopView.isHidden = !isNavigationTitleHidden
            animateFloatingTitle(show: isNavigationTitleHidden)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = events.count - 1
        if indexPath.row >= lastElement, updateAvailable {
            currentPage += 1
            updateEvents(page: currentPage)
        }
    }
}

extension EventsViewController: EventTableViewCellDelegate, PictureDownloadDelegate {
    func pictureDownloadFailed(indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func categorySelected(_ category: String) {
        if let hashTagVC = UIStoryboard.get(flow: .eventsFlow).get(controller: .hashTagEventsVC) as? HashTagEventsViewController {
            hashTagVC.category = category
            
            AnalyticsManager.shared.logEvent(name: Constants.Events.subject)
            
            show(hashTagVC, sender: self)
        }
    }
    
    func tagSelected(_ tag: String) {
        if let hashTagVC = UIStoryboard.get(flow: .eventsFlow).get(controller: .hashTagEventsVC) as? HashTagEventsViewController {
            hashTagVC.tag = tag
            
            let params: [String : Any] = [Constants.Parameters.place : "\(Constants.Parameters.pulse) tag"]
            AnalyticsManager.shared.logEvent(name: Constants.Events.pressedTag, parameters: params)
            
            show(hashTagVC, sender: self)
        }
    }
    
    func placeSelected(_ place: String) {
        if let hashTagVC = UIStoryboard.get(flow: .eventsFlow).get(controller: .hashTagEventsVC) as? HashTagEventsViewController {
            hashTagVC.place = place
            
            AnalyticsManager.shared.logEvent(name: Constants.Events.subject)
            
            show(hashTagVC, sender: self)
        }
    }
}

extension EventsViewController: TagsSearchDelegate {
    func searchBy(tags: [String]) {
        updateEvents(hashtags: tags)
    }
}

extension EventsViewController: OpenURLDelegate {
    func open(url: URL) {
        WebViewManager.shared.openURL(url, from: self, title: "")
        AnalyticsManager.shared.logEvent(name: Constants.Events.switchToSource)
    }
}

extension EventsViewController: TutorialDelegate {
    func dismissTutorialView() {
        tutorialView?.removeFromSuperview()
    }
}

extension EventsViewController: APDNativeAdQueueDelegate, APDNativeAdPresentationDelegate {
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

private extension APDNativeAd {
    func show(on superview: UIView, controller: UIViewController) {
        getViewFor(controller).map {
            superview.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leftAnchor.constraint(equalTo: superview.leftAnchor),
                $0.rightAnchor.constraint(equalTo: superview.rightAnchor),
                $0.topAnchor.constraint(equalTo: superview.topAnchor),
                $0.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
    }
}
