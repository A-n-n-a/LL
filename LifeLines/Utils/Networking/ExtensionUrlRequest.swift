//
//  ExtensionUrlRequest.swift
//  TapTaxi-New
//
//  Created by Anna on 4/23/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation

extension URLRequest {
    
    mutating func addHttpBody(parameters: [String: Any]) {
        do {
            
            if let _ = parameters["locations"] as? [String] {
                //for save locations settings request
            } else {
                let jsonObject = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                httpBody = jsonObject
            }
        } catch let error {
            #if DEBUG
            print(error)
            #endif
        }
    }
    
    mutating func addHeaders(_ headers: [String: String]?) {
        var headers: [String: String] = headers ?? [:]
        headers["Content-Type"] = "application/json;charset=UTF-8"
        headers["Accept"] = "application/json;charset=UTF-8"
        if let userId = UserDefaults.standard.string(forKey: "UserId") {
            #if DEBUG
            print("USER ID: \(userId)")
            #endif
            headers["UserId"] = userId
        }
        
        for (headerField, value) in headers {
            setValue(value, forHTTPHeaderField: headerField)
        }
    }
    
}
