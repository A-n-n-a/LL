//
//  SourceTableViewCell.swift
//  LifeLines
//
//  Created by Anna on 4/1/20.
//  Copyright © 2020 Anna. All rights reserved.
//

import UIKit

class SourceTableViewCell: UITableViewCell {

    @IBOutlet weak var sourceLabel: UILabel!
    
    var event: Event? {
        didSet {
            setUpCell()
        }
    }
    
    func setUpCell() {
        
        sourceLabel.text = event?.sourceName
    }
    @IBAction func openSource(_ sender: Any) {
        if let urlString = event?.url, let url = URL(string: urlString),
            let topVC = UIApplication.topViewController() {
            WebViewManager.shared.openURL(url, from: topVC, title: "")
            AnalyticsManager.shared.logEvent(name: Constants.Events.switchToSource)
        }
    }
}
