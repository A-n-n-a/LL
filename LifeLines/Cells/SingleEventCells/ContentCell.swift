//
//  ContentCell.swift
//  LifeLines
//
//  Created by Anna on 9/2/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit
import WebKit

protocol ContentCellDelegate {
    func eventContentLoaded(height: CGFloat, eventId: String)
}

class ContentCell: UITableViewCell {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var webViewHeight: NSLayoutConstraint!
    
    var event: Event? {
        didSet {
            setUpCell()
        }
    }
    
    var delegate: ContentCellDelegate?
    
    func setUpCell() {
        webView.navigationDelegate = self
        if let content = event?.content {
            
            webView.scrollView.isScrollEnabled = false
            webView.loadHTMLString(content, baseURL: nil)
        }
    }
}

extension ContentCell: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            print(self.event!.title)
            print(webView.scrollView.contentSize)
            print("")
            let height = webView.scrollView.contentSize.height
            self.webViewHeight.constant = height
            if let id = self.event?.id {
                self.delegate?.eventContentLoaded(height: height, eventId: id)
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated,
            let url = navigationAction.request.url,
            let topVC = UIApplication.topViewController() {
            WebViewManager.shared.openURL(url, from: topVC, title: nil)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
