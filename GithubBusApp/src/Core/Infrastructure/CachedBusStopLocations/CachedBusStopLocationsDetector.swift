//
//  FirstLaunchDetector.swift
//  GithubBusApp
//
//  Created by James Mallison on 03/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Foundation

/// Detects whether or not this the application has successfully cached the necessary bus stop locations from our json file
struct CachedBusStopLocationsDetector
{
    /// The key stored in user defaults
    private let userDefaultsKey: String = CachedBusStopLocations.dataSaveCompletedKey
    
    /// Persistence mechanism
    private let userDefaults: UserDefaults
    
    /// Whether or not we have cached the locations successfully before
    public var hasCachedLocationsSuccessfully: Bool {
        get {
            return self.userDefaults.bool(forKey: self.userDefaultsKey)
        }
    }

    /// Initialise an instance of `BusStopLocationsCachedDetector`, setting user defaults to contain true
    ///
    /// - Parameter userDefaults: The persistence mechanism for permanently storing whether or or not the locations have been cached successfully
    init(withUserDefaults userDefaults: UserDefaults)
    {
        userDefaults.set(true, forKey: self.userDefaultsKey)
        
        self.userDefaults = userDefaults
    }
    
    /// Typically for development or to cause some other once-only action to re-occur, removing value from user defaults
    public func setToNotCachedLocationsYet() -> Void
    {
        self.userDefaults.removeObject(forKey: self.userDefaultsKey)
    }
}
