//
//  ExtensionsRestApiManager.swift
//  TapTaxi-New
//
//  Created by Anna on 4/23/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation
import UIKit

// MARK: Call method with Load indicator
extension RestApiManager {
    
    /// Object call
    ///
    /// - Parameters:
    ///   - method: RestApiMethod
    ///   - completion: Result<T>
    func call<T: Associated>(method: RestApiMethod,
                             indicator: Bool,
                             completion: @escaping (_ result: Result<T>) -> Void) {
        showStatusBarLoadIndicator()
        call(method: method) { (result: Result<T>) in
            completion(result)
            self.hideStatusBarLoadIndicator()
        }
    }
    
    /// Array call
    ///
    /// - Parameters:
    ///   - method: RestApiMethod
    ///   - completion: Result<[T]>
    ///
    /// - Parameters:
    ///   - method: RestApiMethod
    ///   - completion: Result<T>
    func call<T: Associated>(method: RestApiMethod,
                             indicator: Bool,
                             completion: @escaping (_ result: Result<[T]>) -> Void) {
        showStatusBarLoadIndicator()
        call(method: method) { (result: Result<[T]>) in
            completion(result)
            self.hideStatusBarLoadIndicator()
        }
    }
    
    /// Multipart call
    ///
    /// - Parameters:
    ///   - multipartData: MultipartData
    ///   - method: RestApiMethod
    ///   - completion: Result<T>
    func call<T: Associated>(multipartData: MultipartData,
                             method: RestApiMethod,
                             indicator: Bool,
                             completion: @escaping (_ result: Result<T>) -> Void) {
        showStatusBarLoadIndicator()
        call(multipartData: multipartData, method: method) { (result: Result<T>) in
            completion(result)
            self.hideStatusBarLoadIndicator()
        }
    }
    
    /// String call
    ///
    /// - Parameters:
    ///   - method: RestApiMethod
    ///   - completion: Result<String>
    func call(method: RestApiMethod, indicator: Bool, completion: @escaping (_ result: Result<String>) -> Void) {
        showStatusBarLoadIndicator()
        call(method: method) { (result: Result<String>) in
            completion(result)
            self.hideStatusBarLoadIndicator()
        }
    }
}

// MARK: - StatusBar load indicator
extension RestApiManager {
    func showStatusBarLoadIndicator() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    func hideStatusBarLoadIndicator() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}
