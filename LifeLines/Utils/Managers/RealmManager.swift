//
//  RealmManager.swift
//  LifeLines
//
//  Created by Anna on 7/7/19.
//  Copyright © 2019 Anna. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmManager {
    
    static let schemaVersion: UInt64 = 7
    
    //=========================================================
    // MARK: - Initialization
    //=========================================================
    @discardableResult init?() {
        guard RealmManager.prepareRealmDatabase() else {
            return nil
        }
    }
    
    @discardableResult private static func prepareRealmDatabase(deleteExistingDatabase: Bool = false) -> Bool {
        
        var configRealm = Realm.Configuration()
        guard let fileUrl = configRealm.fileURL else { return false }
        do {
            let schemaVersion = try schemaVersionAtURL(fileUrl)
            #if DEBUG
            print("schema version \(schemaVersion)")
            print(fileUrl)
            #endif
        } catch  {
            #if DEBUG
            print(error)
            #endif
        }
        

        configRealm.schemaVersion = RealmManager.schemaVersion
        configRealm.migrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < RealmManager.schemaVersion {
                RealmMigrationManager.migrateWith(migration, fromOld: oldSchemaVersion,
                                                  toNew: RealmManager.schemaVersion)
            }
        }
        
        Realm.Configuration.defaultConfiguration = configRealm
        return RealmManager.tryOpenRealm(recreateDBIfFaild: !deleteExistingDatabase)
    }
    
    //=========================================================
    // MARK: - Actions
    //=========================================================
    /// Add any object to database
    ///
    /// - Parameter object: Object that is child of Object class
    /// - Returns: Returns true if operatio was successful
    @discardableResult class func add(object: Object) -> Bool {
        do {
            let realm = try Realm(configuration: Realm.Configuration.defaultConfiguration)
            
            try realm.write {
                realm.add(object)
            }
            return true
        } catch {
            return false
        }
    }
    
    /// Get a list of object from database
    ///
    /// - Parameters:
    ///   - type: Type of needed object
    ///   - withFilter: Rooles to find objects from response
    /// - Returns: List of objects
    class func getObjects<T: Object>(type: T.Type, withFilter: String?) -> Results<T>? {
        do {
            let realm = try Realm(configuration: Realm.Configuration.defaultConfiguration)
            if let filter = withFilter {
                return realm.objects(type).filter(filter)
            } else {
                return realm.objects(type)
            }
        } catch {
            return nil
        }
    }
    
    /// Get object from database
    ///
    /// - Parameters:
    ///   - type: Type of needed object
    ///   - forPrimaryKey: Object's primaryKey
    /// - Returns: Object
    class func getObject<T: Object>(type: T.Type, forPrimaryKey: String?) -> T? {
        do {
            let realm = try Realm(configuration: Realm.Configuration.defaultConfiguration)
            return realm.object(ofType: type, forPrimaryKey: forPrimaryKey)
        } catch {
            return nil
        }
    }
    
    /// Delete objects from database
    ///
    /// - Parameter list: List that contains objects from database
    /// - Returns: Returns true if operation was successful
    @discardableResult class func deleteObjectsList<T: Object>(list: List<T>) -> Bool {
        return RealmManager.deleteObjects(objects: list)
    }
    
    /// Delete objects from database
    ///
    /// - Parameter Results: Object of type Results that contains objects from database
    /// - Returns: Returns true if operation was successful
    @discardableResult class func deleteObjectsResults<T: Object>(results: Results<T>) -> Bool {
        return RealmManager.deleteObjects(objects: results)
    }
    
    /// Delete object from database
    ///
    /// - Parameter Object: object from database
    /// - Returns: Returns true if operation was successful
    @discardableResult class func deleteObject<T: Object>(object: T) -> Bool {
        let list = List<T>()
        list.append(object)
        
        return deleteObjects(objects: list)
    }
    
    /// Delete object from database
    ///
    /// - Parameter Object: object from database
    /// - Returns: Returns true if operation was successful
    @discardableResult class func deleteObject<T: Object>(object: T?) -> Bool {
        guard let object = object else {
            return false
        }
        
        return deleteObject(object: object)
    }
    
    @discardableResult class func addOrUpdate(object: Object) -> Bool {
        do {
            let realm = try Realm(configuration: Realm.Configuration.defaultConfiguration)
            
            try realm.write {
                realm.add(object, update: .all)
            }
            
            return true
        } catch {
            return false
        }
    }
    
    @discardableResult class func addOrUpdate(objects: [Object]) -> Bool {
        do {
            let realm = try Realm(configuration: Realm.Configuration.defaultConfiguration)
            
            try realm.write {
                realm.add(objects, update: .modified)
            }
            
            return true
        } catch {
            return false
        }
    }
    
    private class func deleteObjects<T: Object>(objects: List<T>) -> Bool {
        do {
            let realm = try Realm(configuration: Realm.Configuration.defaultConfiguration)
            try realm.write {
                realm.delete(objects)
            }
            
            return true
        } catch {
            return false
        }
    }
    
    private class func deleteObjects<T: Object>(objects: Results<T>) -> Bool {
        do {
            let realm = try Realm(configuration: Realm.Configuration.defaultConfiguration)
            try realm.write {
                realm.delete(objects)
            }
            
            return true
        } catch {
            return false
        }
    }
    
    private class func tryOpenRealm(recreateDBIfFaild: Bool = true) -> Bool {
        do {
            _ = try Realm(configuration: Realm.Configuration.defaultConfiguration)
            return true
        } catch let error as NSError {
            if (error.code == Realm.Error.Code.fileAccess.rawValue) && recreateDBIfFaild {
                
                return prepareRealmDatabase(deleteExistingDatabase: true)
            } else {
                
                return false
            }
        }
    }
}

