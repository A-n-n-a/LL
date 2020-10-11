//
//  AppDelegate.swift
//  LifeLines
//
//  Created by Anna on 7/6/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import UIKit
import RealmSwift
import FacebookCore
import Amplitude
import YandexMobileMetrica
import AppsFlyerLib
import OneSignal
import UserNotifications
import Appodeal
import ApiTapiAB

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        RealmManager()
        registerForPushNotifications()
        
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")

        //AppsFlyer
        AppsFlyerTracker.shared().appsFlyerDevKey = "ajUR9ABFiNAN88xtYg9mwM";
        AppsFlyerTracker.shared().appleAppID = "1477801503"
        AppsFlyerTracker.shared().delegate = self
//        AppsFlyerTracker.shared().isDebug = true
       
       //Amplitude
        Amplitude.instance()?.useAdvertisingIdForDeviceId()
        Amplitude.instance()?.initializeApiKey("4e3c7c1f1166177581044a68a36e6afa")
        
        //AppMetrica
        if let configuration = YMMYandexMetricaConfiguration.init(apiKey: "4bd51d49-e467-4ac1-9027-7024671d4f37") {
            YMMYandexMetrica.activate(with: configuration)
        }
        
        //OneSignal
        
        //Remove this method to stop OneSignal Debugging
        OneSignal.setLogLevel(.LL_ERROR, visualLevel: .LL_NONE)
        
        
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in

           print("Received Notification: \(notification!.payload.notificationID)")
        }

        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
           // This block gets called when the user reacts to a notification received
           let payload: OSNotificationPayload = result!.notification.payload
            
            let params = [Constants.Parameters.notificationId : payload.notificationID]
            AnalyticsManager.shared.logUserProperty(params)
           var fullMessage = payload.body
           print("Message = \(fullMessage)")

           if payload.additionalData != nil {
              if payload.title != nil {
                 let messageTitle = payload.title
                    print("Message Title = \(messageTitle!)")
              }

              let additionalData = payload.additionalData
              if additionalData?["actionSelected"] != nil {
                 fullMessage = fullMessage! + "\nPressed ButtonID: \(additionalData!["actionSelected"])"
              }
           }
        }

        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false,
           kOSSettingsKeyInAppLaunchURL: false]

        OneSignal.initWithLaunchOptions(launchOptions,
           appId: "22c2e671-cfdf-4926-8960-b9d498418cd4",
           handleNotificationReceived: notificationReceivedBlock,
           handleNotificationAction: notificationOpenedBlock,
           settings: onesignalInitSettings)

        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        //Appodeal
        let adTypes: AppodealAdType = [.interstitial, .nativeAd]
        Appodeal.setLogLevel(.off)
        Appodeal.setTestingEnabled(false)
        Appodeal.initialize(withApiKey: "b51850dce91ee8735c26d253f3fb3fe2ec78a01cff410daa", types: adTypes, hasConsent: false)

        trackLaunch()
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.activateApp()
        AppsFlyerTracker.shared().trackAppLaunch()
//        AppEventsLogger.activate(application)
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

// MARK: - Handling APNS
extension AppDelegate {
    
    func registerForPushNotifications() {
      UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound, .badge]) {
          [weak self] granted, error in
            
          print("Permission granted: \(granted)")
          guard granted else { return }
          self?.getNotificationSettings()
      }
    }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        //ApiTapi
        let ab = ApiTapiAB(authToken: "92953f711fbf0c23ace8a90d", deviceToken: token)

        #if DEBUG
        print("Device Token: \(token)")
        #endif
        

//        FirebaseManager.shared.didRegisterForRemoteNotifications(deviceToken: deviceToken)
        AppsFlyerTracker.shared().registerUninstall(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        FirebaseManager.shared.didFailToRegisterForRemoteNotifications(error: error)
    }
}

extension AppDelegate: AppsFlyerTrackerDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        print(conversionInfo)
    }
    
    func onConversionDataFail(_ error: Error) {
        print(error)
    }
    
    private func onAppOpenAttribution(_ attributionData: [String : Any]) {
        print(attributionData)
    }
    
    func onAppOpenAttributionFailure(_ error: Error) {
        print(error)
    }
}


extension AppDelegate {
    func trackLaunch() {
        
        
        if !UserDefaults.standard.bool(forKey: Constants.Keys.udWasLaunched) {
            
            let calendar = Calendar.current
            guard let day = Date().numberOfDays() else { return }
            let week = calendar.component(.weekOfYear, from: Date())
            let month = calendar.component(.month, from: Date())
            
            let params: [String : Any] = [Constants.Parameters.cohortDay : day,
                Constants.Parameters.cohortWeek : week,
                Constants.Parameters.cohortMonth : month]
            
            AnalyticsManager.shared.logEvent(name: Constants.Events.firstLaunch, properties: params)
            UserDefaults.standard.set(true, forKey: Constants.Keys.udWasLaunched)
        }
        AnalyticsManager.shared.logEvent(name: Constants.Events.sessionStart)
    }
}
