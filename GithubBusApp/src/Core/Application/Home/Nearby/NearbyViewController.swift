//
//  NearbyViewController.swift
//  GithubBusApp
//
//  Created by James Mallison on 11/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import UIKit
import AwaitKit
import Hero

/// The view controller for "Nearby", which contains the container view controller containing the bus stop cards that the user can swipe between
class NearbyViewController: UIViewController
{
    /// The service used to retrieve the users location
    public var userLocator: UserLocator?
    
    /// Contains the locations of all the bus stops on the island
    public var busStopLocationRepository: BusStopLocationRepository?
    
    /// The service used to retrieve the bus times
    public var busTimesService: BusTimesService?
    
    /// The instance of `UICollectionViewController` embedded via a `UIContainerView` in the storyboard
    fileprivate weak var collectionViewController: NearbyCollectionViewController? {
        get {
            guard let collectionViewController = self.childViewControllers.first as? NearbyCollectionViewController else {
                return nil
            }
            
            return collectionViewController
        }
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        async {
            guard let userLocation = self.userLocator?.getUsersCurrentLocation() else {
                return
            }
            
            guard let closestLocations = self.busStopLocationRepository?.findClosest(
                self.collectionViewController?.numberOfCellsToShow ?? 0, toLocation: userLocation
            ) else {
                return
            }

            // The ids required to make API requests
            let busStopIds = closestLocations.compactMap({
                 return Int32($0.busStopId)
            })
            
            var busStops: [BusStop] = []
            
            // We could use a dispatch group here and fire an async callback once all have finished to reload data...
            for busStopId in busStopIds {
                guard let busStop = self.busTimesService?.get(forStopNumber: Int(busStopId)) else {
                    continue
                }

                busStops.append(busStop)
            }
            
            self.collectionViewController?.addBusStops(busStops, withCurrentLocation: userLocation)
        }
    }
}
