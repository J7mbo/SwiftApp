//
//  UnmanagedEntityId.swift
//  GithubBusApp
//
//  Created by James Mallison on 03/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import CoreData

/// Value object used to retain a reference to it's `NSManagedObjectID` for updating / deletion purposes later on
class UnmanagedEntityId: NSObject
{
    /// The id can be represented as a string, which can be convered into a `URL` and then finally an `NSManagedObjectID`
    public let id: String
    
    /// Typically this is initialised by `ReadRepository` or `WriteRepository`
    ///
    /// - Parameter objectId: The id from the `NSManagedObject` instance
    init(withObjectId objectId: NSManagedObjectID)
    {
        self.id = objectId.uriRepresentation().absoluteString
    }
    
    /// Used in `WriteRepository` to delete / update an entity by this id
    ///
    /// - Parameter context: The context from the `ReadRepository` or `WriteRepository`
    ///
    /// - Returns: An instance of `NSManagedObjectID`, if the `NSPersistentStoreCoordinator` is not nil
    public func getIdAsObjectId(viaContext context: NSManagedObjectContext) -> NSManagedObjectID?
    {
        return context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: URL(string: self.id)!)
    }
}
