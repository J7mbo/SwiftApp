//
//  BusStopLocation.swift
//  GithubBusApp
//
//  Created by James Mallison on 03/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Foundation
import CoreLocation

/// Represents a bus stop location, cached in persistance on initial app load, with a latitude and a longitude
class BusStopLocation: NSObject, UnmanagedEntity
{
    /// Used for identifying an `NSManagedObject`, for deletion and updating purposes for example
    @objc public var id: UnmanagedEntityId?
    
    /// The unique id
    @objc public let busStopId: Int32
    
    /// The latitude
    @objc public let latitude: Float
    
    /// The longitude
    @objc public let longitude: Float
    
    /// The location name
    @objc public let name: String

    /// Initialise a `BusStopLocation`
    ///
    /// - Parameters:
    ///   - busStopId: The unique id
    ///   - latitude:  The latitude
    ///   - longitude: The longitude
    ///   - name:      The location name
    ///   - id:        Used for identifying an `NSManagedObject`, for deletion and updating purposes for example
    init(busStopId: Int32, latitude: Float, longitude: Float, name: String, id: UnmanagedEntityId? = nil)
    {
        self.busStopId = busStopId
        self.latitude  = latitude
        self.longitude = longitude
        self.name      = name
        self.id        = id
    }
    
    /// Get the location of the bus stop
    ///
    /// - Returns: The `CLLocation` of the `BusStop`
    public func asCLLocation() -> CLLocation
    {
        return CLLocation.init(latitude: Double(self.latitude), longitude: Double(self.longitude))
    }    
}
