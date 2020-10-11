//
//  RestApiData.swift
//  TapTaxi-New
//
//  Created by Anna on 4/23/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation

/// RestApiData
public struct RestApiData {
    var url: String
    var httpMethod: HttpMethod
    var headers: [String: String]?
    var parameters: [String: Any]
    var keyPath: String?
    var customTimeoutInterval: TimeInterval?
    
    init(url: String,
         httpMethod: HttpMethod,
         headers: [String: String]? = nil,
         parameters: ParametersProtocol? = nil,
         keyPath: String? = nil) {
        self.url = url
        self.httpMethod = httpMethod
        self.headers = headers
        self.keyPath = keyPath
        self.parameters = parameters?.dictionaryValue ?? [:]
    }
}

extension RestApiData {
    var urlWithParametersString: String {
        var parametersString = ""
        for (offset: index, element: (key: key, value: value)) in parameters.enumerated() {
            parametersString += "\(key)=\(value)"
            if index < parameters.count - 1 {
                parametersString += "&"
            }
        }
        parametersString = parametersString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        if !parametersString.isEmpty {
            parametersString = "?" + parametersString
        }
        return url + parametersString
    }
}
