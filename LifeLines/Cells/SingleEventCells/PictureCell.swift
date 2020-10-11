//
//  PictureCell.swift
//  LifeLines
//
//  Created by Anna on 9/2/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class PictureCell: UITableViewCell {

    @IBOutlet weak var picture: CustomImageView!
    @IBOutlet weak var photoContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var event: Event? {
        didSet {
            setUpCell()
        }
    }
    
    private var urlString: String?
    var delegate: PictureDownloadDelegate?
    var indexPath: IndexPath!
    
    func setUpCell() {
        
        guard let event = event else { return }
        
        setPicture(event: event)
    }
    
    func setPicture(event: Event) {
        photoContainerHeight.constant = 50
        picture.isHidden = true
        if let imageLink = event.imageLink, !imageLink.isEmpty, imageLink != "{}", !imageLink.contains("{") {
            urlString = imageLink
            if let urlString = urlString,  !UserDefaults.standard.bool(forKey: urlString) {
                retrieveImgeFromLink(imageLink)
                photoContainerHeight.constant = UIScreen.main.bounds.width / 2
                picture.isHidden = false
            }
//            picture.isHidden = false
//            retrieveImgeFromLink(imageLink)
//            photoContainerHeight.constant = UIScreen.main.bounds.width / 2
        } else {
            picture.isHidden = true
        }
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
        self.photoContainerHeight.constant = 50
        if let urlString = urlString {
            UserDefaults.standard.set(true, forKey: urlString)
        }
        delegate?.pictureDownloadFailed(indexPath: self.indexPath)
        #if DEBUG
        print("==================================")
        print("Retrieving image failure")
        print("Link: ", link)
        print(error?.localizedDescription)
        print("==================================")
        #endif
    }
}
