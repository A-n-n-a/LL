//
//  RestApiManager.swift
//  TapTaxi-New
//
//  Created by Anna on 4/23/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation

/// Associated
public typealias Associated = Decodable

/// URLSessionRestApiManager
open class URLSessionRestApiManager: RestApiManager {
    
    private let session = URLSession(configuration: .default,
                                     delegate: nil,
                                     delegateQueue: nil)
    
    /// Object call
    ///
    /// - Parameters:
    ///   - method: RestApiMethod
    ///   - completion: Result<T>
    public func call<T: Associated>(method: RestApiMethod, completion: @escaping (_ result: Result<T>) -> Void) {
        createDataTask(method: method, completion: completion)
    }
    
    /// Array call
    ///
    /// - Parameters:
    ///   - method: RestApiMethod
    ///   - completion: Result<[T]>
    public func call<T: Associated>(method: RestApiMethod, completion: @escaping (_ result: Result<[T]>) -> Void) {
        createDataTask(method: method, completion: completion)
    }
    
    /// Multipart call
    ///
    /// - Parameters:
    ///   - multipartData: MultipartData
    ///   - method: RestApiMethod
    ///   - completion: Result<T>
    public func call<T: Associated>(multipartData: MultipartData,
                                    method: RestApiMethod,
                                    completion: @escaping (_ result: Result<T>) -> Void) {
        guard let request = request(method: method) else {
            completion(.failure(LLError.unknown))
            return
        }
        
        session.uploadTask(with: request, from: multipartData.data) { (data, _, error) in
            self.handleResponse(data: data, error: error, completion: completion, completionHandler: { (data) in
                self.handleResponse(data: data, method: method, completion: completion)
            })
            }.resume()
    }
    
    /// String call
    ///
    /// - Parameters:
    ///   - method: RestApiMethod
    ///   - completion: Result<String>
    public func call(method: RestApiMethod, completion: @escaping (_ result: Result<String>) -> Void) {
        createDataTask(method: method, completion: completion) { (data) in
            if let answer = String(data: data, encoding: .utf8) {
                completion(.success(answer))
            } else {
                completion(.failure(LLError.unknown))
            }
        }
    }
    
    /// Standart url call
    ///
    /// - Parameters:
    ///   - url: The URL to be retrieved
    ///   - completion: The completion handler to call when the load request is complete.
    ///     This handler is executed on the delegate queue.
    public func downloadData(url: URL,
                             completion: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        showStatusBarLoadIndicator()
        session.dataTask(with: url) {[weak self] (data, response, error) in
            self?.hideStatusBarLoadIndicator()
            completion(data, response, error)
            }.resume()
    }
    
    deinit {
        #if DEBUG
        print(" --- URLSessionRestApiManager deinit --- ")
        #endif
        hideStatusBarLoadIndicator()
    }
    
}

// MARK: - DataTask
extension URLSessionRestApiManager {
    private func createDataTask<T: Associated>(method: RestApiMethod,
                                               completion: @escaping (_ result: Result<T>) -> Void) {
        createDataTask(method: method, completion: completion) { (data) in
            self.handleResponse(data: data, method: method, completion: completion)
        }
    }
    
    private func createDataTask<T>(method: RestApiMethod,
                                   completion: @escaping (_ result: Result<T>) -> Void,
                                   completionHandler: @escaping (Data) -> Swift.Void) {
        showStatusBarLoadIndicator()
        createDataTask(method: method) { (data, _, error) in
            self.hideStatusBarLoadIndicator()
            self.handleResponse(data: data, error: error, completion: completion, completionHandler: completionHandler)
        }
    }
    
    private func createDataTask(method: RestApiMethod,
                                completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        guard let request = request(method: method) else {
            completionHandler(nil, nil, LLError.unknown)
            return
        }
        
        let dataTask = session.dataTask(with: request) { (data, urlResponse, error) in
            
            // Completion Handler
            completionHandler(data, urlResponse, error)
            
            if let httpResponse = urlResponse as? HTTPURLResponse {
                if let userId = httpResponse.allHeaderFields["UserId"] as? String {
                    #if DEBUG
                    print("USER ID: \(userId)")
                    #endif
                    UserDefaults.standard.set(userId, forKey: "UserId")
                }
            }
            
            // Print response
            #if DEBUG
            self.printDataResponse(urlResponse, request: request, data: data)
            #endif
        }
        dataTask.resume()
    }
    
}

// MARK: - Handle Response
extension URLSessionRestApiManager {
    private func handleResponse<T: Associated>(data: Data,
                                               method: RestApiMethod,
                                               completion: @escaping (_ result: Result<T>) -> Void) {
        #if DEBUG
        print("\n\n-------------------------------------------------------------")
        print("RESPONSE:\n\t\(String(describing: String(data: data, encoding: .utf8)))")
        print("METHOD:\n\t\(method)")
        print("\n\n-------------------------------------------------------------")
        #endif
        do {
            let object = try JSONDecoder().decode(T.self, from: data)
            completion(.success(object))
        } catch {
            if let responseError = try? JSONDecoder().decode(ResponseError.self, from: data), let errorText = responseError.errors.global.first?.text {
                completion(.failure(LLError(error: errorText)))
            } else {
                completion(.failure(LLError(error: "Неизвестная ошибка. Попробуйте позже")))
            }
        }
    }
    
    private func handleResponse<T>(data: Data?,
                                   error: Error?,
                                   completion: @escaping (_ result: Result<T>) -> Void,
                                   completionHandler: @escaping (Data) -> Swift.Void) {
        if let error = error {
            // Hadle Error
            completion(.failure(LLError(error: error)))
        } else if let data = data {
            // Hadle Data
            handleInternalResponseError(data: data, completion: completion, completionHandler: completionHandler)
        } else {
            // Hadle unknown result
            completion(.failure(LLError.unknown))
        }
    }
}

// MARK: - Handle error
extension URLSessionRestApiManager {
    private func handleInternalResponseError<T>(data: Data,
                                                completion: @escaping (_ result: Result<T>) -> Void,
                                                completionHandler: @escaping (Data) -> Swift.Void) {
        do {
            let error = try JSONDecoder().decode(LLError.self, from: data, keyPath: "error")
            completion(.failure(error))
        } catch {
            completionHandler(data)
        }
    }
}

// MARK: - Request
extension URLSessionRestApiManager {
    private func request(method: RestApiMethod) -> URLRequest? {
        var hashtagUrl: URL?
        if let hashtags = method.data.parameters["hashtag"] as? [String] {
            var queryItems = [URLQueryItem]()
            for tag in hashtags {
                let item = URLQueryItem(name: "hashtag", value: tag)
                queryItems.append(item)
            }
            if let page = method.data.parameters["page"] as? Int {
                let item = URLQueryItem(name: "page", value: "\(page)")
                queryItems.append(item)
            }
            if let urlComps = NSURLComponents(string: Constants.Links.baseURL) {
                urlComps.queryItems = queryItems
                hashtagUrl = urlComps.url
            }
        }
        
        var urlString = method.data.urlWithParametersString
        if let _ = method.data.parameters["locations"] as? [String] {
            #if DEBUG
            print("URL: ", method.data.url)
            #endif
            urlString =  method.data.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? method.data.urlWithParametersString
        }
        
        guard let url = hashtagUrl ?? URL(string: urlString) else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = method.data.customTimeoutInterval ?? 30.0
        urlRequest.httpMethod = method.data.httpMethod.rawValue
        urlRequest.addHeaders(method.data.headers)
        if method.data.httpMethod != .get {
            urlRequest.addHttpBody(parameters: method.data.parameters)
        }
        return urlRequest
    }
}

// MARK: - Show request and responce info
extension URLSessionRestApiManager {
    private func printDataResponse(_ dataResponse: URLResponse?, request: URLRequest, data: Data?) {
        var printResponse = false
        
        print("\n\n-------------------------------------------------------------")
        defer {
            print("-------------------------------------------------------------\n\n")
        }
        
        if let httpBody = request.httpBody {
            if let parameters = String(data: httpBody, encoding: .utf8),
                (parameters.range(of: "p22") != nil || parameters.range(of: "p21") != nil ||
                    parameters.range(of: "p62") != nil || parameters.range(of: "p34") != nil ||
                    parameters.range(of: "p69") != nil) {
                printResponse = false
            }
        }
        
        #if DEBUG
        print("REQUEST:\n\t\(request)")
        #endif
        if let httpBody = request.httpBody {
            if let parameters = String(data: httpBody, encoding: .utf8) {
                #if DEBUG
                print("\tparameters: \(parameters)")
                #endif
            }
        }
        do {
            if let data = data, printResponse {
                #if DEBUG
                print("RESPONSE:\n\(try JSONSerialization.jsonObject(with: data, options: .allowFragments))")
                #endif
            }
        } catch {}
    }
}

