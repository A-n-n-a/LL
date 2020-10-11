//
//  ArticlesCell.swift
//  LifeLines
//
//  Created by Anna on 9/2/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class ArticlesCell: UITableViewCell {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var articles = [AlternativeEvent]() {
        didSet {
            tableView.alpha = articles.isEmpty ? 0 :1
            tableView.reloadData()
        }
    }

    var event: Event? {
        didSet {
            setUpCell()
        }
    }
    
    var delegate: SingleEventCollectionViewCellDelegate?
    
    func setUpCell() {
        
        guard let event = event else { return }
        
        tableView.registerCell(for: ArticleTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        
        self.articles = Array(event.events)
        
        tableViewHeight.constant = tableViewHeight(items: event.events.count)
    }
    
    func tableViewHeight(items: Int) -> CGFloat {
        
        var totalHeight: CGFloat = 50 //header height
        
        for item in 0..<items {
            let cellHeight = articleCellHeight(index: item)
            totalHeight += cellHeight
        }
        
        return totalHeight
    }
    
    func articleCellHeight(index: Int) -> CGFloat {
        guard let events = event?.events else { return 0 }
        let basicHeight: CGFloat = 56
        let article = events[index]
        let label = UILabel()
        label.text = article.title
        let labelWidth = UIScreen.main.bounds.width - 64
        let labelHeight = CGFloat(label.calculateMaxLines(width: labelWidth) * 22)
        return basicHeight + labelHeight
    }
    
}

extension ArticlesCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ArticleTableViewCell.self)) as! ArticleTableViewCell
        cell.event = articles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let eventId = articles[indexPath.row].id
        delegate?.showArticle(id: eventId)
    }
}
