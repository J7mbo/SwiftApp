//
//  WriteRepository.swift
//  GithubBusApp
//
//  Created by James Mallison on 26/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit
import AwaitKit

/// Writes are with `WriteRepository` in a background context, reads are with `ReadRepository` in the main view context
class WriteRepository: NSObject
{
    /// This should be the main persistent container from `AppDelegate`
    private let container: NSPersistentContainer
    
    /// Initialise a `WriteRepository`
    ///
    /// - Parameters:
    ///   - container: This should be the main persistent container from `AppDelegate`
    required init(_ container: NSPersistentContainer)
    {
        /** Propagates changes down to the viewContext, which causes NSFetchedResultsController to be notified **/
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        self.container  = container
    }
    
    /// Save an entity to persistence
    ///
    /// - Parameters:
    ///   - entity:           The entity to save
    ///   - flushImmediately: Defaults to true, but if false, don't save the context (useful for multiple saves)
    ///
    /// - Important: If you set flushImmediately to false, you will get back a forced permanent `NSObjectID`
    ///              so you *must* follow up with another call with flushImmediately set to true, otherwise the id will be invalid
    ///
    /// - Returns A promise resolving to a boolean for whether or not persisting succeeded
    public func save(_ entity: AnyObject, flushImmediately: Bool = true) -> Promise<Any>
    {
        return Promise { resolve, reject in
            self.container.performBackgroundTask { (context) in
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                guard let obj: AnyClass = NSClassFromString(String(describing: type(of: entity)) + "Entity") else {
                    return resolve(false)
                }

                guard let managedObjectType = obj.self as? ManagedEntity.Type else {
                    return resolve(false)
                }
                
                guard var managedObject: NSManagedObject & ManagedEntity = managedObjectType.mapFromUnmanagedEntity(
                    entity, context: context
                ) as? NSManagedObject & ManagedEntity else {
                    return resolve(false)
                }
                
                context.insert(managedObject)
                
                if (flushImmediately == false) {
                    try! context.obtainPermanentIDs(for: [managedObject])
                    
                    let objectIdString = managedObject.objectID.uriRepresentation().absoluteString
                    managedObject.id = objectIdString
                    
                    return resolve(managedObject)
                }
                
                do {
                    try context.save()
                    
                    let objectIdString = managedObject.objectID.uriRepresentation().absoluteString
                    
                    managedObject.id = objectIdString
                    
                    return resolve(managedObject.mapToUnmanagedEntity() as Any)
                } catch {
                    return reject(error)
                }
            }
        }
    }
    
    /// TODO: This should resolve to Promise<[entity: success/failure]> so the user knows what entities failed?
    /// Save multiple entities to persistence
    ///
    /// - Parameters:
    ///   - entities: The entities to save
    ///
    /// - Returns: A promise resolving to an array of the saved entities
    public func save(_ entities: [AnyObject]) -> Promise<Any>
    {
        return Promise { resolve, reject in
            var results: Array<Any> = []
            
            for i in 0...entities.count {
                let entity = entities[i]
                
                if i != entities.count {
                    results.append(try! await(self.save(entity, flushImmediately: false)))

                    continue
                }
                
                results.append(try! await(self.save(entity, flushImmediately: true)))
            }
            
            return resolve(results)
        }
    }
    
    /// Delete every entity of a given name
    ///
    /// - Parameters:
    ///   - entityName: The entity name like "BusStopLocation" to delete
    ///
    /// - Returns: A promise resolving to whether or not the entities were deleted
    public func deleteAll(entityName: String) -> Promise<Bool>
    {
        return Promise { resolve, reject in
            self.container.performBackgroundTask { (context) in
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                
                fetchRequest.returnsObjectsAsFaults = false

                do {
                    let results = try context.fetch(fetchRequest)

                    for managedObject in results {
                        guard let managedObjectData: NSManagedObject = managedObject as? NSManagedObject else {
                            return resolve(false)
                        }

                        context.delete(managedObjectData)
                    }
                    
                    try? context.save()
                    
                    return resolve(true)
                } catch {
                    return resolve(false)
                }
            }
        }
    }
    
    /// Remove an entity from persistence
    ///
    /// - Parameters:
    ///   - entityId:         The id of the entity to delete
    ///   - flushImmediately: Defaults to true, but if false, don't save the context (useful for multiple deletes - save on the last one only)
    ///
    /// - Returns: A promise resolving to a boolean for whether or not the deletion succeeded
//    public func delete(_ entityId: UnmanagedEntityId, flushImmediately: Bool = true) -> Promise<Bool>
//    {
//        return Promise { resolve, reject in
//            self.container.performBackgroundTask { (context) in
//                guard let objectId = entityId.getIdAsObjectId(viaContext: context) else {
//                    return resolve(false)
//                }
//
//                let object = context.object(with: objectId)
//
//                context.delete(object)
//
//                if flushImmediately == false {
//                    return resolve(true)
//                }
//
//                do {
//                    try context.save()
//
//                    return resolve(true)
//                } catch {
//                    return reject(error)
//                }
//            }
//        }
//    }
    
    /// Remove multiple entities from persistence
    ///
    /// - Parameters:
    ///   - entityIds: The ids of the entities to delete
    ///
    /// - Returns: A promise resolving to an array of [idString: boolean] for successes or failures for each entity id
    public func delete(_ entityIds: [UnmanagedEntityId]) -> Promise<Array<[String: Bool]>>
    {
        return Promise { resolve, reject in
            var results: Array<[String: Bool]> = []
            
            if entityIds.isEmpty {
                return resolve(results)
            }
            
            self.container.performBackgroundTask { (context) in
                for i in 1...entityIds.count {
                    /** Arrays start at WHAT!? **/
                    let entityId = entityIds[i-1]
                    
                    guard let objectId = entityId.getIdAsObjectId(viaContext: context) else {
                        results.append([entityId.id: false])
                        
                        continue
                    }
                    
                    let object = context.object(with: objectId)
                    
                    context.delete(object)
                    
                    /** Don't flush until we're the last in the result set, otherwise we're blowing I/O away and we're not pirates! **/
                    if i != entityIds.count {
                        results.append([entityId.id: true])

                        continue
                    }

                    /** Last in result set, we can flush! **/
                    results.append([entityId.id: true])
                    
                    do {
                        try context.save()
                    } catch {
                        return reject(error)
                    }
                }
            }
            
            return resolve(results)
        }
    }
}
