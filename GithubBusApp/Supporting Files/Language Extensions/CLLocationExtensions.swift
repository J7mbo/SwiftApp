//
//  CLLocationExtensions.swift
//  GithubBusApp
//
//  Created by James Mallison on 04/08/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import CoreLocation.CLLocation

extension CLLocation
{
    /// Get the distance this location is from another location, as a string (60.4 becomes "60")
    ///
    /// - Parameter location: The location to compare this location against
    public func distanceFromAsString(location: CLLocation) -> String
    {
        let formatter = NumberFormatter()

        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0

        return formatter.string(from: NSNumber(value: location.distance(from: self)))!
    }
}
