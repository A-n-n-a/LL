//
//  TagsView.swift
//  LifeLines
//
//  Created by Anna on 7/15/20.
//  Copyright © 2020 Anna. All rights reserved.
//

import UIKit

protocol TagsViewDelegate {
    func updateTagsViewHeight(collectionViewHeight: CGFloat)
    func tagSelected(_ tag: String)
}

class TagsView: UIView {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var flowLayout: LeftAlignmentFlowLayout!
    
    var tags = [String]() {
        didSet {
            collectionView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.heightConstraint.constant = self.collectionView.contentSize.height
                self.delegate?.updateTagsViewHeight(collectionViewHeight: self.collectionView.contentSize.height)
            }
        }
    }
    
    let cellId = String(describing: TagViewCollectionViewCell.self)
    var delegate: TagsViewDelegate?
    
    //=========================================================
    // MARK: - Initialization
    //=========================================================
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        prepareUI()
    }
    
    func prepareUI() {
        addSelfNibUsingConstraints()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerCell(for: TagViewCollectionViewCell.self)
        
        flowLayout.padding = 16
    }
}

extension TagsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return  tags.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  cellId, for: indexPath) as! TagViewCollectionViewCell
        
        if indexPath.row < tags.count {
            let tag = tags[indexPath.item]
            cell.tagTitle = tag
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tag = tags[indexPath.item]
        let size: CGSize = tag.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)])
        
        let height: CGFloat = 34
        return CGSize(width: size.width + 20, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tag = tags[indexPath.item]
        delegate?.tagSelected(tag)
    }
}
