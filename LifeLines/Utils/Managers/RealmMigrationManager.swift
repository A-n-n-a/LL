//
//  RealmMigrationManager.swift
//  LifeLines
//
//  Created by Anna on 7/7/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

final class RealmMigrationManager {
    class func migrateWith(_ migration: Migration, fromOld oldSchemaVersion: UInt64, toNew newSchemaVersion: UInt64) {
        for index in (oldSchemaVersion + 1)...newSchemaVersion {
            #if DEBUG
            print(" >>> Migrating to \(index) version...")
            #endif
            guard let manualMigrationVersion = Constants.RealmManualMigrationVersion(rawValue: index) else {
                continue
            }
            route(migration, manualMigrationVersion)
        }
        
        #if DEBUG
        print(" >>> Migration finished.")
        #endif
    }
    
    private class func route(_ migration: Migration, _ schemaVersion: Constants.RealmManualMigrationVersion) {
        switch schemaVersion {
        case .addCities:
            clearDatabase(migration)
        case .clearDataBase:
            clearDatabase(migration)
        }
    }
    
//    private class func gateWayFix(_ migration: Migration) {
//        resetTimeStamp(migration)
//    }
    
    /// PMRecentOperation object had primary key "token" and they were grouped by token.
    /// From now on, we are using contract number as recent operations primary key
    /// Existing users could have two operations with diferent token but same contract number
    /// This migration fixes possible duplication of the same contract number.
    /// If two or more objects with the same contract number exists ->
    /// we will delete each of them untill only one object with the same contract number
    /// will be presented in the database
//    private class func recentOperationPrimaryKeyChanges(_ migration: Migration) {
//        var contractNumbers: [String] = []
//        migration.enumerateObjects(ofType: PMRecentOperation.className()) { (oldObject, _) in
//            if let oldObject = oldObject {
//                if let contractNumber = oldObject["contractNumber"] as? String, !contractNumber.isEmpty {
//                    if contractNumbers.contains(contractNumber) {
//                        migration.delete(oldObject)
//                    } else {
//                        contractNumbers.append(contractNumber)
//                    }
//                } else {
//                    migration.delete(oldObject)
//                }
//            }
//        }
//    }
    
//    private class func deleteAllPayeesFromDatabase(_ migration: Migration) {
//        resetTimeStamp(migration)
//        migration.enumerateObjects(ofType: PMPayee.className()) { (oldObject, _) in
//            if let oldObject = oldObject {
//                migration.delete(oldObject)
//            }
//        }
//    }
    
//    private class func resetTimeStamp(_ migration: Migration) {
//        migration.enumerateObjects(ofType: PayeesDataTimestamp.className(), { _, newObject in
//            if let newObject = newObject {
//                newObject["timestamp"] = 0
//            }
//        })
//    }
    
    private class func clearDatabase(_ migration: Migration) {
        
        migration.enumerateObjects(ofType: Category.className()) { (oldObject, _) in
            if let oldObject = oldObject {
                migration.delete(oldObject)
            }
        }

        migration.enumerateObjects(ofType: SearchResult.className()) { (oldObject, _) in
            if let oldObject = oldObject {
                migration.delete(oldObject)
            }
        }
    }
    
}

