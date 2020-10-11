//
//  ParametersProtocol.swift
//  TapTaxi-New
//
//  Created by Anna on 4/23/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation

/// ParametersProtocol
public protocol ParametersProtocol {
    typealias Parameters = [String: Any]
    
    var dictionaryValue: Parameters { get }
}
