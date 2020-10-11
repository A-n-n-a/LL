//
//  EventTableViewCell.swift
//  LifeLines
//
//  Created by Anna on 7/6/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

protocol EventTableViewCellDelegate {
    func tagSelected(_ tag: String)
    func categorySelected(_ category: String)
    func placeSelected(_ place: String)
}

protocol PictureDownloadDelegate {
    func pictureDownloadFailed(indexPath: IndexPath)
}

protocol OpenURLDelegate {
    func open(url: URL)
}

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var photoContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var picture: CustomImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var tagsCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var event: Event? {
        didSet {
            if let topics = event?.topics {
                
                self.topics = Array(topics)
            }
            if let locations = event?.locations {
                var locationsArray = Array(locations)
                locationsArray = locationsArray.map({ (location) -> String in
                    return location.capitalized
                })
                self.topics += locationsArray
            }
            if let tags = event?.tags {
                var array = Array(tags)
                if let tag = selectedTag {
                    array.bringToFront(item: tag)
                }
                self.tags = array
            }
            setUpCell()
        }
    }
    
    var selectedTag: String?
    var selectedCategory: String?
    var selectedPlace: String?
    private var urlString: String?
    
    var topics = [String]() {
        didSet {
            tagsCollectionView.reloadData()
        }
    }
    var tags = [String]() {
        didSet {
            tagsCollectionView.reloadData()
        }
    }
    
    var delegate: EventTableViewCellDelegate?
    var urlDelegate: OpenURLDelegate?
    var pictureDelegate: PictureDownloadDelegate?
    var indexPath: IndexPath!
    let cellId = String(describing: TagCollectionViewCell.self)
    
    func setUpCell() {
        setShadow()
        setUpCollectionView()
        
        guard let event = event else { return }
        photoContainerHeight.constant = 0
        picture.isHidden = true
        if let imageLink = event.imageLink, !imageLink.isEmpty, imageLink != "{}", !imageLink.contains("{") {
            self.urlString = imageLink
            
            if let urlString = urlString,  !UserDefaults.standard.bool(forKey: urlString) {
                retrieveImgeFromLink(imageLink)
                photoContainerHeight.constant = UIScreen.main.bounds.width / 2
                picture.isHidden = false
            }
            
        } else {
            
            picture.isHidden = true
        }
        
        titleLabel.text = event.title
        sourceLabel.text = event.sourceName
        
        var length: CGFloat = 36
        for topic in topics {
            let size: CGSize = topic.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .bold)])
            length += (size.width + 20)
        }
        
        let bgColorView = UIView(frame: CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height - 10))
        bgColorView.backgroundColor = .white
        selectedBackgroundView = bgColorView
    }
    
    func setShadow() {
        shadowView.layer.shadowColor = UIColor.kShadow.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 6)
        shadowView.layer.shadowOpacity = 0.25
        shadowView.layer.shadowRadius = 10
    }
    
    func setUpCollectionView() {
        
        tagsCollectionView.delegate = self
        tagsCollectionView.dataSource = self
        tagsCollectionView.registerCell(for: TagCollectionViewCell.self)
        tagsCollectionViewHeight.constant = 36 + getCategoriesTagsHeight()
    }
    
    func getCategoriesTagsHeight() -> CGFloat {
        var width: CGFloat = 16 + 8 + 40 + 40 //paddings
        for topic in topics {
            let size: CGSize = topic.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold)])
            width += size.width
        }
        return width > UIScreen.main.bounds.width ? 68 : 30
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tagsCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func retrieveImgeFromLink(_ link: String) {
        activityIndicator.startAnimating()
        urlString = link
        
        guard let url = URL(string: link) else {
            downloadFailureHandling()
            return
        }
        
        picture.image = nil
        
        if let imageFromCache = CacheManager.shared.fetchImage(for: link), self.urlString == link {
            activityIndicator.stopAnimating()
            picture.image = imageFromCache
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data(contentsOf: url)
                DispatchQueue.main.async() {
                    if let imageToCache = UIImage(data: data) {
                        
                        if self.urlString == link {
                            self.activityIndicator.stopAnimating()
                            CacheManager.shared.saveImage(imageToCache, for: link)
                            self.picture.image = imageToCache
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async() {
                    self.activityIndicator.stopAnimating()
                    self.downloadFailureHandling(error: error)
                }
            }
        }
    }

    func downloadFailureHandling(error: Error? = nil) {
        self.photoContainerHeight.constant = 0
        if let urlString = urlString {
            UserDefaults.standard.set(true, forKey: urlString)
        }
        self.pictureDelegate?.pictureDownloadFailed(indexPath: self.indexPath)
        #if DEBUG
        print("==================================")
        print("Retrieving image failure")
        print("Link: ", link)
        print(error?.localizedDescription)
        print("==================================")
        #endif
    }
}

extension EventTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return section == 0 ? topics.count : tags.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  cellId, for: indexPath) as! TagCollectionViewCell
        let items = indexPath.section == 0 ? topics : tags
        cell.type = indexPath.section == 0 ? .topic : .tag
        if indexPath.row < items.count {
            let tag = items[indexPath.item]
            cell.selectedTag = selectedTag ?? selectedCategory ?? selectedPlace
            cell.tagTitle = tag
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let items = indexPath.section == 0 ? topics : tags
        let tag = items[indexPath.item]
        let fontSize: CGFloat = indexPath.section == 0 ? 14 : 12
        let fontWeight: UIFont.Weight = indexPath.section == 0 ? .bold : .regular
        let size: CGSize = tag.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize, weight: fontWeight)])
        
        let height: CGFloat = indexPath.section == 0 ? 30 : 24
        return CGSize(width: size.width + 20, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let category = topics[indexPath.row]
                delegate?.categorySelected(category)
            } else {
                let place = topics[indexPath.row]
                delegate?.placeSelected(place)
            }
        } else {
            let tag = tags[indexPath.item]
            delegate?.tagSelected(tag)
        }
    }
}
