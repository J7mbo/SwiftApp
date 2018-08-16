//
//  BusStop.swift
//  TestWeb
//
//  Created by James Mallison on 10/12/2017.
//  Copyright © 2017 J7mbo. All rights reserved.
//

import CoreLocation

/// A Bus Stop that the user can visit
struct BusStop
{
    /// The unique bus stop number
    private(set) var stopNumber: Int
    
    /// The location that the bus stop is outside of
    private(set) var stopAddress: String
    
    /// The lines running at this stop
    private(set) var busLines: [BusLine]

    /// Every `BusStop` must have a location (the locations are stored separately in a database, imported from json currently)
    private(set) var location: CLLocation
}

