//
//  CustomImageView.swift
//  LifeLines
//
//  Created by Anna on 8/30/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {

    var urlString: String?
    
    func retrieveImgeFromLink(_ link: String) {
        
        urlString = link
        
        guard let url = URL(string: link) else { return }
        
        self.image = nil
        
        if let imageFromCache = CacheManager.shared.fetchImage(for: link), self.urlString == link {
            self.image = imageFromCache
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data(contentsOf: url)
                DispatchQueue.main.async() {
                    if let imageToCache = UIImage(data: data) {
                        
                        if self.urlString == link {
                            CacheManager.shared.saveImage(imageToCache, for: link)
                            self.image = imageToCache
                        }
                    }
                }
            } catch {
                #if DEBUG
                print("==================================")
                print("Retrieving image failure")
                print("Link: ", link)
                print(error.localizedDescription)
                print("==================================")
                #endif
            }
        }
    }

}
