//
//  BusStopLocation+CoreDataClass.swift
//  
//
//  Created by James Mallison on 03/03/2018.
//
//

import Foundation
import CoreData

@objc(BusStopLocationEntity)

public class BusStopLocationEntity: NSManagedObject, ManagedEntity
{
    @NSManaged public var id: String?
    @NSManaged public var bus_stop_id: Int32
    @NSManaged public var latitude: Float
    @NSManaged public var longitude: Float
    @NSManaged public var name: String!
}

extension BusStopLocationEntity
{
    public static func mapFromUnmanagedEntity(_ entity: AnyObject, context: NSManagedObjectContext) -> Self?
    {
        if !(entity is BusStopLocation) {
            return nil
        }
        
        let managedEntity = self.init(context: context)
        
        managedEntity.id          = entity.objectID?.uriRepresentation().absoluteString
        managedEntity.bus_stop_id = entity.busStopId!
        managedEntity.latitude    = entity.latitude!
        managedEntity.longitude   = entity.longitude!
        managedEntity.name        = entity.name!
        
        return managedEntity
    }
    
    public func mapToUnmanagedEntity() -> Any?
    {
        return BusStopLocation(
            busStopId: self.bus_stop_id,
            latitude: self.latitude,
            longitude: self.longitude,
            name: self.name,
            id: UnmanagedEntityId(withObjectId: self.objectID)
        )
    }
}
