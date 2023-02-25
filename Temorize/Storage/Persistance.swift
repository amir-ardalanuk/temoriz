//
//  Persistance.swift
//  Temorize
//
//  Created by ardalan on 2/15/23.
//

import Foundation
import RealmSwift

public typealias CodableObject = Object

// sourcery: AutoMockable
public protocol DatabaseManagerProtocol {
    func get<T: CodableObject>(type: T.Type, filter: NSPredicate?) throws -> Results<T>
    func get<T: CodableObject>(type: T.Type, by primaryKey: Any) throws -> T?
    func add(object: CodableObject, update: Bool?) throws
    func add(objects: [CodableObject], update: Bool?) throws
    func update<T: CodableObject>(object: T, operation: @escaping (T) -> Void) throws
    func update<T: CodableObject>(object: T, operation: @escaping (T, Realm) -> Void) throws
    func update<T: CodableObject>(object: [T], operation: @escaping ([T]) -> Void) throws
    func remove(object: CodableObject) throws
    func remove(objects: [CodableObject]) throws
    func remove<T: CodableObject>(type: T.Type, filter: NSPredicate?) throws
    func removeAll<T: CodableObject>(type: T.Type) throws
    func resetDB() throws
}

enum DatabaseError: Error {
    case failedToOpen
}

final public class DatabaseManager: DatabaseManagerProtocol {

    public init() { }

    public func get<T: CodableObject>(type: T.Type, filter: NSPredicate? = nil) throws -> Results<T> {
        do {
            return try autoreleasepool { () -> Results<T> in
                let realm = try Realm()
                if let predicate = filter {
                    return realm.objects(T.self).filter(predicate)
                } else {
                    return realm.objects(T.self)
                }
            }
        } catch let error as NSError {
            #if Kiliaro
            LogError("Error getting object from Realm \(error)")
            #endif
            throw DatabaseError.failedToOpen
        }
    }

    public func get<T: CodableObject>(type: T.Type, by primaryKey: Any) throws -> T? {
        do {
            let realm = try Realm()
            return realm.object(ofType: T.self, forPrimaryKey: primaryKey)
        } catch let error as NSError {
            throw DatabaseError.failedToOpen
        }
    }

    public func add(object: CodableObject, update: Bool? = nil) throws {
        do {
            let realm = try Realm()
            try realm.write {
                if update != nil {
                    realm.add(object, update: .modified)
                } else {
                    realm.add(object)
                }
            }
        } catch let error as NSError {
            throw DatabaseError.failedToOpen
        }
    }

    public func add(objects: [CodableObject], update: Bool? = nil) throws {
        do {
            let realm = try Realm()
            try realm.write {
                if update != nil {
                    realm.add(objects, update: .modified)
                } else {
                    realm.add(objects)
                }
            }
        } catch let error as NSError {
            throw DatabaseError.failedToOpen
        }
    }

    public func update<T: CodableObject>(object: T, operation: @escaping (T) -> Void) throws {
        do {
            try autoreleasepool {
                let realm = try Realm()
                try realm.write {
                    operation(object)
                }
            }
        } catch let error as NSError {
            throw DatabaseError.failedToOpen
        }
    }

    public func update<T: CodableObject>(object: T, operation: @escaping (T, Realm) -> Void) throws {
        do {
            try autoreleasepool {
                let realm = try Realm()
                try realm.write {
                    operation(object, realm)
                }
            }
        } catch let error as NSError {
            throw DatabaseError.failedToOpen
        }
    }

    public func update<T: CodableObject>(object: [T], operation: @escaping ([T]) -> Void) throws {
        do {
            let realm = try Realm()
            try realm.write {
                operation(object)
            }
        } catch let error as NSError {
            throw DatabaseError.failedToOpen
        }
    }

    public func remove(object: CodableObject) throws {
        do {
            try autoreleasepool {
                let realm = try Realm()
                try realm.write {
                    realm.delete(object)
                }
            }
        } catch let error as NSError {
            throw DatabaseError.failedToOpen
        }
    }

    public func remove(objects: [CodableObject]) throws {
        do {
            try autoreleasepool {
                let realm = try Realm()
                try realm.write {
                    realm.delete(objects)
                }
            }
        } catch let error as NSError {
            throw DatabaseError.failedToOpen
        }
    }

    public func remove<T: CodableObject>(type: T.Type, filter: NSPredicate?) throws {
        do {
            let realm = try Realm()
            try realm.write {
                if let predicate = filter {
                    realm.delete(realm.objects(T.self).filter(predicate))
                } else {
                    realm.delete(realm.objects(T.self))
                }
            }
        } catch let error as NSError {
            throw DatabaseError.failedToOpen
        }
    }

    public func resetDB() throws {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch let error as NSError {
            throw DatabaseError.failedToOpen
        }
    }

    public func removeAll<T: CodableObject>(type: T.Type) throws {
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(realm.objects(T.self))
            }
        } catch let error as NSError {
            throw DatabaseError.failedToOpen
        }
    }
}
