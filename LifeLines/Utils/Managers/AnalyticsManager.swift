//
//  AnalyticsManager.swift
//  LifeLines
//
//  Created by Anna on 1/21/20.
//  Copyright © 2020 Anna. All rights reserved.
//

import UIKit
import FacebookCore
import Amplitude
import AppsFlyerLib
import OneSignal

class AnalyticsManager {
    
    static let shared = AnalyticsManager()
    
    private init() {}
    
    func logEvent(name: String, parameters: [String: Any] = [:], properties: [String: Any] = [:]) {
        AppEvents.logEvent(AppEvents.Name(rawValue: name), parameters: parameters)
        Amplitude.instance()?.logEvent(name, withEventProperties: parameters)
        AppsFlyerTracker.shared().trackEvent(name, withValues: parameters)
        
        let identify = AMPIdentify()
        guard !properties.isEmpty else { return }
        for (key, value) in properties {
            identify.set(key, value: value as? NSObject)
        }
        Amplitude.instance()?.identify(identify)
    }
    
    func logEventOneSignal(name: String, properties: [String: Any] = [:]) {
        let identify = AMPIdentify()
        guard !properties.isEmpty else { return }
        for (key, value) in properties {
            identify.set(key, value: value as? NSObject)
        }
        Amplitude.instance()?.identify(identify)
        
        OneSignal.sendTags(properties)
    }
    
    func logUserProperty(_ properties: [String: Any]) {
        let identify = AMPIdentify()
        guard !properties.isEmpty else { return }
        for (key, value) in properties {
            identify.set(key, value: value as? NSObject)
        }
        Amplitude.instance()?.identify(identify)
    }
}
