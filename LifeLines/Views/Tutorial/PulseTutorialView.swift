//
//  PulseTutorialView.swift
//  LifeLines
//
//  Created by Anna on 4/25/20.
//  Copyright © 2020 Anna. All rights reserved.
//

import UIKit

protocol TutorialDelegate {
    func dismissTutorialView()
}

class PulseTutorialView: UIView {
    
    @IBOutlet weak var topCategoryConstraint: NSLayoutConstraint!
    @IBOutlet weak var topTagsConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var tagsView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var container1: UIView!
    @IBOutlet weak var container2: UIView!
    @IBOutlet weak var container3: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: TutorialDelegate?
    
    var events = [Event]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUpView()
    }
    
    
    func setUpView() {
        addSelfNibUsingConstraints()
        
        container1.layer.borderColor = UIColor.kPurpleBorder.cgColor
        container2.layer.borderColor = UIColor.kPurpleBorder.cgColor
        container3.layer.borderColor = UIColor.kPurpleBorder.cgColor
        setTopConstraint()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(for: EventTableViewCell.self)
        tableView.registerCell(for: HeaderCell.self)
        
        dateLabel.text = Date().toString(format: Constants.DateFormats.titleFormat).uppercased()
    }
    
    func setTopConstraint() {
        let hasImage = EventsManager.events.first?.imageLink != nil
        var offset = UIApplication.shared.statusBarFrame.height + 100
        offset += hasImage ? 270 : 63
        topCategoryConstraint.constant = offset
        offset += 40
        topTagsConstraint.constant = offset
        layoutIfNeeded()
    }
    
    @IBAction func switchHint(_ sender: Any) {
        if pageControl.currentPage == 0 {
            titleLabel.text = "Фильтруйте события\nпо тэгам"
            nextButton.setTitle("Начать", for: .normal)
            pageControl.currentPage = 1
            categoryView.isHidden = true
            tagsView.isHidden = false
        } else {
            delegate?.dismissTutorialView()
        }
    }
}

extension PulseTutorialView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeaderCell.self)) as! HeaderCell
            cell.selectionStyle = .none
            cell.backgroundColor = .white
            cell.contentView.backgroundColor = .white
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventTableViewCell.self)) as! EventTableViewCell
        cell.indexPath = indexPath
        cell.event = events[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60
        }
        return UITableView.automaticDimension
    }
    
}
