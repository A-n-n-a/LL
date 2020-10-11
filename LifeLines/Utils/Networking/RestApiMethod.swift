//
//  RestApiMethod.swift
//  TapTaxi-New
//
//  Created by Anna on 4/23/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation

/// RestApiMethod
public protocol RestApiMethod {
    var data: RestApiData { get }
}

/// HttpMethod
public enum HttpMethod: String {
    case options = "OPTIONS"
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case trace = "TRACE"
    case connect = "CONNECT"
}

extension RestApiMethod {
    var url: String {
        
        return Constants.Links.baseURL
    }
}

extension RestApiMethod {
    static func ==(lhs: RestApiMethod, rhs: RestApiMethod) -> Bool {
        if let left = lhs as? TemplatesAPIRequest,
            let right = rhs as? TemplatesAPIRequest {
            return left.url == right.url
        }
        return false
    }
}
