//
//  BusStopLocationRepository.swift
//  GithubBusApp
//
//  Created by James Mallison on 19/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation.CLLocation

/// Responsible for handling the persistence of a `BusStopLocation`
class BusStopLocationRepository: ReadRepository
{
    fileprivate let entityName = BusStopLocationEntity.self
    
    /// This should be the main persistent container from `AppDelegate`
    private let container: NSPersistentContainer
    
    /// Initialise a `BusStopLocationRepository`
    ///
    /// - Parameters:
    ///   - container: This should be the main persistent container from `AppDelegate`
    required init(_ container: NSPersistentContainer)
    {
        self.container = container
        
        super.init(container)
    }
    
    /// Retrieve all `BusStopLocation`s from persistence
    ///
    /// - Returns: All the `BusStopLocation`s in persistence
    public func findAll() -> [BusStopLocation]
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: self.entityName))
        
        guard let locations = try? self.container.viewContext.fetch(fetchRequest) as? [BusStopLocationEntity] else {
            return []
        }
        
        var unmanagedLocations: [BusStopLocation] = []
        
        for location in locations! {
            if let unmanagedLocation = location.mapToUnmanagedEntity() as? BusStopLocation {
                unmanagedLocations.append(unmanagedLocation)
            }
        }
        
        return unmanagedLocations
    }
    
    /// Retrieve a `BusStopLocation` from persistence, mapped from `BusStopLocationEntity` internally automatically
    ///
    /// - Parameter stopNum: The bus stop number to retrieve the location for
    ///
    /// - Returns: An instance of `BusStopLocation` if it exists
    public func findByStopNumber(_ stopNum: Int) -> BusStopLocation?
    {
        let context = self.container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: self.entityName))
    
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "bus_stop_id == %@", NSNumber(value: stopNum))
        
        guard let location = try? context.fetch(fetchRequest).first as? BusStopLocationEntity else {
            return nil
        }
        
        return location?.mapToUnmanagedEntity() as? BusStopLocation
    }
    
    /// Retrieve the X closest `BusStopLocation`s to the provided `CLLocation`
    ///
    /// Important: - Retrieves locations from storage. They have been stored there first from (bus_stop_locations.json)
    ///
    /// - Parameters:
    ///   - numberOfStops:      The number of `BusStopLocation`s to retrieve
    ///   - location: The location to find the closest locations for
    ///
    /// - Returns: The closest `BusStopLocation`s to this location
    public func findClosest(_ numberOfStops: Int, toLocation location: CLLocation) -> [BusStopLocation]?
    {
        let locations: [BusStopLocation] = self.findAll()
  
        let locationsSortedByDistance = locations.sorted(by: {
            return $0.asCLLocation().distance(from: location) < $1.asCLLocation().distance(from: location)
        })
        
        return Array(locationsSortedByDistance[0..<numberOfStops])
    }
}
