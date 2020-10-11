//
//  SingleEventViewController.swift
//  LifeLines
//
//  Created by Anna on 7/13/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit
import Appodeal

protocol TagsSearchDelegate {
    func searchBy(tags: [String])
}

class SingleEventViewController: LLViewController, LoaderPresenting {
    
    @IBOutlet weak var tagsSubtitle: UILabel!
    @IBOutlet weak var bottomShareView: UIControl!
    @IBOutlet weak var bottomFavoriteView: UIControl!
    @IBOutlet weak var bottomFavoriteIcon: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var phenomenaCollectionView: UICollectionView!
    @IBOutlet weak var phenomenasFlowLayout: CustomFlowLayout!
    @IBOutlet weak var eventsCollectionView: UICollectionView!
    @IBOutlet weak var eventsFlowLayout: EventsFlowLayout!
    @IBOutlet weak var eventsCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var toolBar: UIView!
    @IBOutlet weak var phenomenaView: UIView!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolbarHeight: NSLayoutConstraint!
    
    var eventId: String?
    var tags = [String]() {
        didSet {
            if tagsSubtitle != nil {
                tagsSubtitle.text = "Явление по #: \(tags.joined(separator: ", "))"
            }
            tagsView.tags = tags
        }
    }
    var event: Event? {
        didSet {
            if let imageLink = event?.imageLink, !imageLink.isEmpty, imageLink != "{}", let url = URL(string: imageLink) {
                
                DispatchQueue.global(qos: .background).async {
                    do {
                        let data = try Data(contentsOf: url)
                        DispatchQueue.main.async() {
                            self.eventImage = UIImage(data: data)
                        }
                    } catch {
                        #if DEBUG
                        print(error)
                        #endif
                    }
                }
            }
//            phenomenas = []
//            if let event = event {
//                phenomenas = [Phenomena(event: event, isSelected: true)]
//                self.dismissLoader()
//                self.contentView.alpha = 1
//                self.phenomenaView.alpha = 1
//            }
            guard let eventId = event?.id else { return }
//            getPhenomena(id: eventId)
            isFavorite = EventsManager.isFavorite(id: eventId)
        }
    }
    var eventImage: UIImage?
    
    var phenomenas = [Phenomena]() {
        didSet {
            DispatchQueue.main.async {
                self.phenomenaCollectionView.reloadData()
                self.eventsCollectionView.reloadData()
                self.phenomenasFlowLayout.itemsCount = self.phenomenas.count
                self.eventsFlowLayout.itemsCount = self.phenomenas.count
            }
        }
    }
    var indexOfCellBeforeDragging = 0
    var isFavorite = false {
        didSet {
            updateFavoriteIcon()
        }
    }
    lazy var loader = LoaderView()
    var delegate: TagsSearchDelegate?
    var currentIndexPath: IndexPath?
    var indexPath: IndexPath? {
        didSet {
            phenomenasFlowLayout.currentIndexPath = indexPath
            eventsFlowLayout.currentIndexPath = indexPath
        }
    }
    var previousOffset: CGFloat = 0
    let itemWidth = UIScreen.main.bounds.width
    let phenomenaItemWidth: CGFloat = 195
    var padding: CGFloat = 0
    var favoriteCell: TitleCell?
    var cardTutorialView: CardTutorialView?
    var tagsTutorialView: TagsTutorialView?
    lazy var tagsView = TagsView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: tagsViewHeight))
    var tagsViewHeight: CGFloat = 270

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tagsSubtitle.text = "Явление по #: \(tags.joined(separator: ", "))"
        
        tabBarController?.tabBar.isHidden = true
        tabBarController?.tabBar.isTranslucent = true

        eventsCollectionView.registerCell(for: SingleEventCollectionViewCell.self)
        phenomenaCollectionView.registerCell(for: PhenomenaCollectionViewCell.self)
        eventsCollectionView.backgroundColor = .white
        eventsCollectionView.backgroundColor = .white
        
        guard let eventId = eventId else { return }
        getPhenomena(id: eventId)
        
        tagsView.delegate = self
        view.addSubview(tagsView)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(hideTags))
        swipe.direction = .down
        tagsView.addGestureRecognizer(swipe)
        
        isFavorite = EventsManager.isFavorite(id: eventId)
        //temp
        indexPath = IndexPath(item: 0, section: 0)
        
        setUpGestures()
        
        toolbarHeight.constant = UIDevice.current.isFrameless() ? 92 : 72
        
        addWatch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func goBack() {
        let watches = UserDefaults.standard.integer(forKey: Constants.Keys.watchesCount)
        if watches % 7 == 0 {
            showInterstitial()
        } else {
            super.goBack()
        }
    }
    
    func showInterstitial() {
        let placement = "default"
        guard
            Appodeal.isInitalized(for: .interstitial),
            Appodeal.canShow(.interstitial, forPlacement: placement)
        else {
            return
        }
        Appodeal.setInterstitialDelegate(self)
        Appodeal.showAd(.interstitial,
                        forPlacement: placement,
                        rootViewController: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func addWatch() {
        var watches = UserDefaults.standard.integer(forKey: Constants.Keys.watchesCount)
        watches += 1
        UserDefaults.standard.set(watches, forKey: Constants.Keys.watchesCount)
    }
    
    func showCardTutorial() {
        if !UserDefaults.standard.bool(forKey: Constants.Keys.udCardTutorialWasShown) {
            cardTutorialView = CardTutorialView(frame: view.frame)
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissCardTutorial))
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dismissCardTutorial))
            cardTutorialView?.addGestureRecognizer(tap)
            cardTutorialView?.addGestureRecognizer(swipe)
            if let tutorialView = cardTutorialView {
                view.addSubview(tutorialView)
                UserDefaults.standard.set(true, forKey: Constants.Keys.udCardTutorialWasShown)
            }
        }
    }
    
    @objc func dismissCardTutorial() {
        cardTutorialView?.removeFromSuperview()
    }
    
    func showTagsTutorial() -> Bool {
        if !UserDefaults.standard.bool(forKey: Constants.Keys.udTagsTutorialWasShown) {
            tagsTutorialView = TagsTutorialView(frame: view.frame)
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissTagsTutorial))
            tagsTutorialView?.addGestureRecognizer(tap)
            tagsTutorialView?.delegate = self
            if let tutorialView = tagsTutorialView {
                view.addSubview(tutorialView)
                UserDefaults.standard.set(true, forKey: Constants.Keys.udTagsTutorialWasShown)
                return true
            }
        }
        return false
    }
    
    @objc func dismissTagsTutorial() {
        tagsTutorialView?.removeFromSuperview()
    }
    
    func getEvent(id: String) {
        contentView.alpha = 0
        phenomenaView.alpha = 0
        showLoader()
        NetworkManager.getSingleEvent(eventId: id) { [weak self] (event, error) in
            DispatchQueue.main.async {
                if let event = event {
                    self?.event = event
                    self?.tags = event.tags
                }
            }
        }
    }
    
    func getPhenomena(id: String) {
        var events = phenomenas
        NetworkManager.newPhenomena(eventId: id) { (phenomena, _) in
            guard let phenomena = phenomena else { return }
            
            let phenomenaEvents = phenomena.events
            self.tags = phenomena.tags
            
            var errorMessage: String?
            
            let updateGroup = DispatchGroup()
            
            DispatchQueue.concurrentPerform(iterations: phenomenaEvents.count) { counterIndex in
                let index = Int(counterIndex)
                let id = phenomenaEvents[index].id
                
                    updateGroup.enter()
                    NetworkManager.getSingleEvent(eventId: id, completion: { (event, error) in
                        if let event = event {
                            let isSelected = id == self.eventId
                            let phenomena = Phenomena(event: event, isSelected: isSelected)
                            events.append(phenomena)
                            if id == self.eventId {
                                self.event = event
                            }
                        } else if let error = error {
                            print("INDEX: ", index)
//                            errorMessage = error.localizedDescription
                        }
                        updateGroup.leave()
                    })
//                }

            }
            updateGroup.notify(queue: DispatchQueue.main) {
                if let errorMessage = errorMessage {
                    self.dismissLoader()
                    self.showError(errorMessage as AnyObject)
                } else {
                    let sortedPhenomenas = events.sorted(by: {
                        if let firstDate = $0.event.date.toDateWith(format: Constants.DateFormats.eventDateFormat), let secondDate = $1.event.date.toDateWith(format: Constants.DateFormats.eventDateFormat) {
                            return firstDate < secondDate
                        }
                        return $0.dateText < $0.dateText
                    })
                    
                    
                    self.phenomenas = sortedPhenomenas
                    self.showCardTutorial()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                        for (index, phenomena) in self.phenomenas.enumerated() {
                            if phenomena.isSelected {
                                
                                if index == self.phenomenas.count - 1, self.phenomenas.count > 1 {
                                    self.leadingConstraint.isActive = false
                                    self.trailingConstraint.isActive = true
                                } else if index != 0 {
                                    self.leadingConstraint.isActive = false
                                    self.centerConstraint.isActive = true
                                }
                                UIView.animate(withDuration: 0.2, animations: {
                                    self.view.layoutIfNeeded()
                                })
                                self.indexPath = IndexPath(item: index, section: 0)
                                self.phenomenaCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
                                self.eventsCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func updateFavoriteIcon() {
        bottomFavoriteIcon.image = isFavorite ? #imageLiteral(resourceName: "icFavFill") : #imageLiteral(resourceName: "icFavNoact")
    }
    
    func setUpGestures() {
        let swipeRight =  UISwipeGestureRecognizer(target: self, action: #selector(swipeRightAction))
        swipeRight.direction = .right
        swipeRight.delegate = self
        eventsCollectionView.addGestureRecognizer(swipeRight)
        
        let swipeLeft =  UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftAction))
        swipeLeft.direction = .left
        swipeLeft.delegate = self
        eventsCollectionView.addGestureRecognizer(swipeLeft)
        
        
        let swipeRightPhenomena =  UISwipeGestureRecognizer(target: self, action: #selector(swipeRightAction))
        swipeRightPhenomena.direction = .right
        swipeRightPhenomena.delegate = self
        phenomenaCollectionView.addGestureRecognizer(swipeRightPhenomena)
        
        let swipeLeftPhenomena =  UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftAction))
        swipeLeftPhenomena.direction = .left
        swipeLeftPhenomena.delegate = self
        phenomenaCollectionView.addGestureRecognizer(swipeLeftPhenomena)
    }
    
    @objc func swipeRightAction() {
        if indexPath?.item != 0 {
            setCellTitleColor(isSelected: false)
            currentIndexPath = indexPath
            indexPath?.item -= 1
            scroll()
        }
    }
    
    @objc func swipeLeftAction() {
        if indexPath?.item != phenomenas.count - 1 {
            setCellTitleColor(isSelected: false)
            currentIndexPath = indexPath
            indexPath?.item += 1
            scroll()
            
            AnalyticsManager.shared.logEvent(name: Constants.Events.watchedPrevious)
        }
    }
    
    func scroll() {
        guard let indexPath = indexPath else { return }
        
        let width = UIScreen.main.bounds.width
        let horizontalOffset = CGFloat(indexPath.item) * width
        let offset = CGPoint(x: horizontalOffset, y: 0)
        
        let event = phenomenas[indexPath.item].event
        isFavorite = event.isFavorite
        
        if indexPath.row == 0 {
            leadingConstraint.isActive = true
            centerConstraint.isActive = false
            trailingConstraint.isActive = false
        } else if indexPath.row == self.phenomenas.count - 1 {
            leadingConstraint.isActive = false
            centerConstraint.isActive = false
            trailingConstraint.isActive = true
        } else {
            leadingConstraint.isActive = false
            centerConstraint.isActive = true
            trailingConstraint.isActive = false
        }
        
        self.eventsCollectionView.setContentOffset(offset, animated: true)
        UIView.animate(withDuration: 0.15) {
            self.eventsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            self.phenomenaCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            
            if let indexPath = self.currentIndexPath, let cell = self.eventsCollectionView.cellForItem(at: indexPath) as? SingleEventCollectionViewCell {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                    if let nextIndexPath = self.indexPath, let nextCell = self.eventsCollectionView.cellForItem(at:  nextIndexPath) as? SingleEventCollectionViewCell {
                        nextCell.layoutIfNeeded()
                        nextCell.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        nextCell.tableView.isScrollEnabled = true
                    }
                    cell.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                })
            }
            
            self.phenomenas.forEach { $0.isSelected = false }
            self.phenomenas[indexPath.row].isSelected = true
            self.setCellTitleColor(isSelected: true)
        }
    }
    
    func scrollPhenomena() {
        guard let indexPath = indexPath else { return }
        
        if indexPath.row == 0 {
            leadingConstraint.isActive = true
            centerConstraint.isActive = false
            trailingConstraint.isActive = false
        } else if indexPath.row == self.phenomenas.count - 1 {
            leadingConstraint.isActive = false
            centerConstraint.isActive = false
            trailingConstraint.isActive = true
        } else {
            leadingConstraint.isActive = false
            centerConstraint.isActive = true
            trailingConstraint.isActive = false
        }
        
        UIView.animate(withDuration: 0.15) {
            self.eventsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            self.phenomenaCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            
            self.phenomenas.forEach { $0.isSelected = false }
            self.phenomenas[indexPath.row].isSelected = true
            self.setCellTitleColor(isSelected: true)
        }
    }
    
    func setCellTitleColor(isSelected: Bool) {
        guard let indexPath = indexPath else { return }
        let cell = phenomenaCollectionView.cellForItem(at: indexPath) as? PhenomenaCollectionViewCell
        cell?.title.textColor = isSelected ? .kPurple : .kLightPurple
    }
    
    func showTags() {
        guard let window = window else { return }
        window.addSubview(blackView)
        window.addSubview(tagsView)
        blackView.frame = window.frame
        
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 1
            
            self.tagsView.transform = CGAffineTransform(translationX: 0, y: -(self.tagsViewHeight - 8))
        }
    }
    
    @objc func hideTags() {
       UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0
            self.window?.endEditing(true)
            self.tagsView.transform = CGAffineTransform.identity
        }
    }
    
    override func handleDismiss() {
        hideTags()
    }
    
    @IBAction func addFavorite(_ sender: Any) {
        guard let eventId = eventId, let event = event else { return }
        if isFavorite {
            isFavorite = false
            favoriteCell?.isFavorite = false
            NetworkManager.deleteFavorite(eventId: eventId) { [weak self] (success, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.isFavorite = true
                        self?.favoriteCell?.isFavorite = true
                        self?.showError(error)
                    }
                    if success {
                        EventsManager.removeFromFavorites(id: eventId)
                        if let cell = self?.favoriteCell {
                            cell.isFavorite = false
                        }
                        self?.isFavorite = false
                        
                        AnalyticsManager.shared.logEvent(name: Constants.Events.newsDeletedInFavorites)
                    }
                }
            }
        } else {
            isFavorite = true
            favoriteCell?.isFavorite = true
            NetworkManager.addFavorite(eventId: eventId) { [weak self] (success, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.isFavorite = false
                        self?.favoriteCell?.isFavorite = false
                        self?.showError(error)
                    }
                    if success {
                        EventsManager.addFavorite(event)
                        AnalyticsManager.shared.logEvent(name: Constants.Events.addToFavorite)
                    }
                }
            }
        }
    }
    
    @IBAction func searchAction(_ sender: Any) {
        
        showTags()
    }
    
    @IBAction func backAction(_ sender: Any) {
        goBack()
    }
    
    @IBAction func toHomePage(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func share(_ sender: Any) {
        if let title = event?.title, let content = event?.content, let decryptedContent = EventsManager.decryptedContent(content)?.string, let url = event?.url {
            var items = [Any]()
            let text = title + "\n" + decryptedContent
            items = [text, url]
            
            if let eventImage = self.eventImage {
                items.insert(eventImage, at: 0)
            }
            
            let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activity.popoverPresentationController?.sourceView = self.view
            activity.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.width - 35, y: 50, width: 5, height: 5)
            
            activity.completionWithItemsHandler = { activity, success, items, error in
                if let activity = activity?.rawValue, let activityName = activity.components(separatedBy: ".").last {
                    let params: [String : Any] = [Constants.Parameters.place : activityName]
                    AnalyticsManager.shared.logEvent(name: Constants.Events.newsSharing, parameters: params)
                }
            }
            self.present(activity, animated: true, completion: nil)
        }
    }
}

extension SingleEventViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return phenomenas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == eventsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  String(describing: SingleEventCollectionViewCell.self), for: indexPath) as! SingleEventCollectionViewCell
            print("CALLED", indexPath.item)
            cell.event = phenomenas[indexPath.item].event
            cell.isFavorite = isFavorite
            cell.setDelegate(self)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  String(describing: PhenomenaCollectionViewCell.self), for: indexPath) as! PhenomenaCollectionViewCell
            cell.phenomena = phenomenas[indexPath.item]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == eventsCollectionView {
            let width = UIScreen.main.bounds.width
            let height = UIScreen.main.bounds.height - toolBar.frame.height - phenomenaView.frame.height
            
            return CGSize(width: width, height: height)
        } else {
            return CGSize(width: 195, height: 52)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? SingleEventCollectionViewCell {
            
            cell.tableView.scrollToRow(at: IndexPath.zero(), at: .top, animated: false)
            cell.tableView.isScrollEnabled = false
        }
    }
}

extension SingleEventViewController: SingleEventCollectionViewCellDelegate {
    func showArticle(id: String) {
        if let singleEventVC = UIStoryboard.get(flow: .eventsFlow).get(controller: .singleEventVC) as? SingleEventViewController {

            singleEventVC.eventId = id
//            singleEventVC.tags = tags
            singleEventVC.delegate = delegate
            
            let params: [String : Any] = [Constants.Parameters.place : "\(Constants.Parameters.suggestions) open"]
            AnalyticsManager.shared.logEvent(name: Constants.Events.newsViewed, parameters: params)
            
            show(singleEventVC, sender: self)
        }
    }
    
    func showFavoriteError(error: Error) {
        showError(error)
    }
    
    func favoriteAdded(_ added: Bool) {
        isFavorite = added
    }
    
    func showBottomFavorite(_ show: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.bottomFavoriteView.alpha = show ? 1 : 0
        }
    }
    
    func favoriteCell(_ cell: TitleCell?) {
        favoriteCell = cell
    }
}

extension SingleEventViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension SingleEventViewController: TutorialDelegate {
    func dismissTutorialView() {
        tagsTutorialView?.removeFromSuperview()
    }
}

extension SingleEventViewController: AppodealInterstitialDelegate {
    func interstitialDidDismiss() {
        super.goBack()
    }
}

extension SingleEventViewController: TagsViewDelegate {
    func updateTagsViewHeight(collectionViewHeight: CGFloat) {
        let defaultHeight: CGFloat = 128
        let frameCopy = tagsView.frame
        tagsViewHeight = defaultHeight + collectionViewHeight
        tagsView.frame = CGRect(x: frameCopy.minX, y: frameCopy.minY, width: frameCopy.width, height: tagsViewHeight)
    }
    
    func tagSelected(_ tag: String) {
        hideTags()
        if let hashTagVC = UIStoryboard.get(flow: .eventsFlow).get(controller: .hashTagEventsVC) as? HashTagEventsViewController {
            hashTagVC.tag = tag
            if let topVC = UIApplication.topViewController() {
                topVC.show(hashTagVC, sender: self)
            }
        }
    }
}
