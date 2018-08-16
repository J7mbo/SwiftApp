//
//  ExpirableUuidEntity+CoreDataProperties.swift
//  
//
//  Created by James Mallison on 01/03/2018.
//
//

import Foundation
import CoreData

@objc(ExpirableUuidEntity)

public class ExpirableUuidEntity: NSManagedObject, ManagedEntity
{
    @NSManaged public var id: String?
    @NSManaged public var created: NSDate!
    @NSManaged public var uuid: String!
}

extension ExpirableUuidEntity
{
    public static func mapFromUnmanagedEntity(_ entity: AnyObject, context: NSManagedObjectContext) -> Self?
    {
        if !(entity is ExpirableUuid) {
            return nil
        }
        
        let managedEntity = self.init(context: context)

        managedEntity.id      = entity.objectID?.uriRepresentation().absoluteString
        managedEntity.uuid    = entity.uuid
        managedEntity.created = entity.created
        
        return managedEntity
    }
    
    public func mapToUnmanagedEntity() -> Any?
    {
        return ExpirableUuid(uuid: self.uuid, created: self.created as Date, id: UnmanagedEntityId(withObjectId: self.objectID))
    }
}
