//
//  Locator.swift
//  GithubBusApp
//
//  Created by James Mallison on 28/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import CoreLocation.CLLocation

/// Represents an object capable of attempting to retrieve the user's current location
protocol UserLocator
{
    /// Retrieve the users current location
    ///
    /// - Returns: A `CLLocation` object if available, or `nil` if unavailable or timed out
    func getUsersCurrentLocation() -> CLLocation?
}
