//
//  Result.swift
//  TapTaxi-New
//
//  Created by Anna on 4/23/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation

/// Result
public enum Result<T> {
    case success(T)
    case failure(LLError)
}
