//
//  PMWebViewManager.swift
//  TapTaxi-New
//
//  Created by Anna on 3/12/19.
//  Copyright © 2019. All rights reserved.
//

import Foundation
import WebKit

class WebViewManager: NSObject {
    
    static let shared = WebViewManager()
    
    private let webView = WKWebView()
    private var cookies = [HTTPCookie]()
    
    func openURL(_ url: URL, from viewController: UIViewController, title: String?) {
        
        guard let request = createRequest(url) else {
            return
        }
        
        let webViewVC = WebViewViewController()
        
        if #available(iOS 11.0, *) {
            for cookie in cookies {
                webViewVC.webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie,
                                                                                        completionHandler: nil)
            }
        }
        if let title = title {
            webViewVC.screenTitle = title
        }
        webViewVC.webView.load(request)
        
        viewController.show(webViewVC, sender: viewController)
    }
    
    private func createRequest(_ url: URL) -> URLRequest? {
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.get.rawValue
        
        return request
    }
}
