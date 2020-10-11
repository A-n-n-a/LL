//
//  TagsTableViewCell.swift
//  LifeLines
//
//  Created by Anna on 4/1/20.
//  Copyright © 2020 Anna. All rights reserved.
//

import UIKit

protocol TagsTableViewCellDelegate {
    func tagSelected(_ tag: String)
    func placeSelected(_ place: String)
}

class TagsTableViewCell: UITableViewCell {

    @IBOutlet weak var topicsCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    var tags = [String]() {
        didSet {
            topicsCollectionView.reloadData()
        }
    }
    
    var delegate: TagsTableViewCellDelegate?
    
    var event: Event? {
        didSet {
            setUpCell()
        }
    }
    
    func setUpCell() {
        
        guard let event = event else { return }
        
        topicsCollectionView.registerCell(for: TagCollectionViewCell.self)
        topicsCollectionView.delegate = self
        topicsCollectionView.dataSource = self
        
        var locationsArray = Array(event.locations ?? [String]())
        locationsArray = locationsArray.map({ (location) -> String in
            return location.capitalized
        })
        
        self.tags = event.tags
        
        let padding: CGFloat = 8
        let offset: CGFloat = 12
        var length: CGFloat = offset
        
        var rows = 1
        for topic in tags {
            let size: CGSize = topic.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
            length += (size.width + 20) + padding
            if length > (UIScreen.main.bounds.width - offset * 2) {
                rows += 1
                length = offset + (size.width + 20) + padding
            }
        }
        
        collectionViewHeight.constant = CGFloat(34 * rows - 10)
    }
}

extension TagsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  String(describing: TagCollectionViewCell.self), for: indexPath) as! TagCollectionViewCell
        let tag = tags[indexPath.item]
        cell.type = .tag
        cell.tagTitle = tag
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tag = tags[indexPath.item]
        let size: CGSize = tag.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
        return CGSize(width: size.width + 20, height: 24)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tag = tags[indexPath.item]
        delegate?.tagSelected(tag)
    }
}
