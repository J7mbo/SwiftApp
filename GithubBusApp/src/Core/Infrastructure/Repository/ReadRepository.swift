//
//  ReadRepository.swift
//  GithubBusApp
//
//  Created by James Mallison on 02/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import CoreData

/// Extend this to provide custom query methods
class ReadRepository: NSObject
{
    /// This should be the main persistent container from `AppDelegate`
    private let container: NSPersistentContainer
    
    /// Initialise a `ReadRepository`
    ///
    /// - Parameters:
    ///   - container: This should be the main persistent container from `AppDelegate`
    required init(_ container: NSPersistentContainer)
    {
        /** Propagates changes down to the viewContext, which causes NSFetchedResultsController to be notified **/
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        self.container  = container
    }
    
    public func fetchAll<T>(_ entity: T.Type) -> [Any]
    {
        let context = self.container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: entity) + "Entity")
    
        let managedObjectResults = try! context.fetch(fetchRequest)
    
        var entityObjects: [Any] = []
    
        for managedObject in managedObjectResults {
            if let managedEntity = managedObject as? ManagedEntity, let entityObject = managedEntity.mapToUnmanagedEntity() {
                entityObjects.append(entityObject)
            }
        }
    
        return entityObjects
    }
}
