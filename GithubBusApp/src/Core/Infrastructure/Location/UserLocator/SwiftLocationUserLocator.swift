//
//  SwiftLocationUserLocator.swift
//  GithubBusApp
//
//  Created by James Mallison on 28/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import CoreLocation.CLLocation
import SwiftLocation
import PromiseKit
import AwaitKit

/// An object that uses the `SwiftLocation` library to attempt to retrieve the user's current location
struct SwiftLocationUserLocator: UserLocator
{
    /// Time in seconds until attempting to retrieve location will fail
    private let retrievalTimeout: Double = 30.0
    
    /// The locator manager from the `SwiftLocation` library
    private let locatorManager: LocatorManager
    
    /// Initialise an instance of `SwiftLocationUserLocator`
    ///
    /// - Parameter locatorManager: The locator manager from the `SwiftLocation` library
    init(withLocatorManager locatorManager: LocatorManager)
    {
        self.locatorManager = locatorManager
    }

    /// Retrieve the current user location
    ///
    /// - Important: Uses await from `AwaitKit`, so make sure you call this from within an `async`
    ///
    /// - Important: The timeout runs even whilst the user has been requested (and has not yet accepted / declined) to provide their location, so while the alert it open
    ///
    /// - Returns: The current user location or nil if it could not be determined
    func getUsersCurrentLocation() -> CLLocation?
    {
        if self.locatorManager.authorizationStatus == CLAuthorizationStatus.denied {
            return nil
        }
        
        return try! await(self.retrieveLocation())
    }
    
    /// Effectively wraps the library call to return a promise, which can be awaited by `getUsersCurrentLocation()`
    ///
    /// - Returns: A promise resolving to the `CLLocation` of the device or nil if it could not be retrieved
    fileprivate func retrieveLocation() -> Promise<CLLocation?>
    {
        return Promise { resolve, _ in
            Locator.currentPosition(
                accuracy: .block,
                timeout: Timeout.after(self.retrievalTimeout),
                onSuccess: { userLocation in
                    return resolve(userLocation)
                },
                onFail: { _, _ in
                    return resolve(nil)
                }
            )
        }
    }
}
