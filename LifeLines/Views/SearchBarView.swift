//
//  SearchBarView.swift
//  LifeLines
//
//  Created by Anna on 7/30/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

protocol SearchBarViewDelegate {
    func searchWithTags(_ tags: [String])
    func cancelSearch()
}

class SearchBarView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: LeftAlignmentFlowLayout!
    @IBOutlet weak var buttonsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    var tags: [String]? {
        didSet {
            tagsCopy = tags
        }
    }
    var tagsCopy: [String]? {
        didSet {
            collectionView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.collectionViewHeight.constant = self.collectionView.contentSize.height
            }
            
            if tagsCopy?.isEmpty ?? true {
                AnalyticsManager.shared.logEvent(name: Constants.Events.deletedTag)
            }
        }
    }
    var delegate: SearchBarViewDelegate?
    var cellName = String(describing: SearchTagCollectionViewCell.self)
    var textFieldCellName = String(describing: TextFieldCollectionViewCell.self)
    var newTag: String?
    var hintsCopy = [String]()
    var query = ""
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
        collectionView.registerCell(for: SearchTagCollectionViewCell.self)
        flowLayout.padding = 10
        
        textField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
        name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func setFirstResponder() {
        textField.becomeFirstResponder()
    }
    
    func cancelFirstResponder() {
        textField.text = ""
        tagsCopy = tags
        textField.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        if let keyboardSize = keyboardFrame?.cgRectValue {
            buttonsBottomConstraint.constant = keyboardSize.height + 24
        }
    }

    @IBAction func cancelSearch(_ sender: Any) {
        cancelFirstResponder()
        delegate?.cancelSearch()
    }
    
    @IBAction func saveSearch(_ sender: Any) {
        saveAction()
    }
    
    @IBAction func deleteAllTags(_ sender: Any) {
        tagsCopy = nil
    }
    
    func saveAction() {
        if var tags = tagsCopy {
            if !query.isEmpty {
                tags.append(query.lowercased())
            }
            delegate?.searchWithTags(tags)
        }
    }
}

extension SearchBarView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagsCopy?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as! SearchTagCollectionViewCell
        cell.tagTitle = tagsCopy?[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tagsCopy?.remove(at: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let tag = tagsCopy?[indexPath.item] else { return CGSize.zero }
        let size: CGSize = tag.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold)])
        return CGSize(width: size.width + 26, height: 34)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension SearchBarView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            query = text.replacingCharacters(in: textRange, with: string)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        saveAction()
        return true
    }
}
