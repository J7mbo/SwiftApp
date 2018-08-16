//
//  BusTimesService.swift
//  GithubBusApp
//
//  Created by James Mallison on 18/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import AwaitKit

/// Retrieve bus times and data over API and transform them into `BusStop` objects
struct BusTimesService
{
    /// The repository containing cached bus stop locations
    private let locationRepository: BusStopLocationRepository
    
    /// The factory for falling back on different api data retrieval strategies - java says "do you want another factory for your factory?"
    private let strategyFactory: DataRetrievalStrategyFactory
    
    /// The Api response mapper (turns data from the factory into a `BusStop`)
    private let responseMapper: ApiResponseMapper
    
    /// Initialise an instance of `BusTimesService`
    ///
    /// - Parameters:
    ///   - locationRepository: The repository containing cached bus stop locations
    ///   - strategyFactory:    The factory for falling back on different api data retrieval strategies
    ///   - responseMapper:     The Api response mapper (turns data from the factory into a `BusStop`)
    init(
        withReadRepository locationRepository: BusStopLocationRepository,
        withDataRetrievalStrategyFactory strategyFactory: DataRetrievalStrategyFactory,
        withResponseMapper responseMapper: ApiResponseMapper
    )
    {
        self.locationRepository = locationRepository
        self.strategyFactory    = strategyFactory
        self.responseMapper     = responseMapper
    }
    
    /// Get the Bus Stop with associated times
    ///
    /// - Important: Uses await from `AwaitKit`, so make sure you call this from within an `async`
    ///
    /// - Parameter stopNumber: The bus stop number to get times for
    ///
    /// - Returns: The `BusStop` with all associated data and times, location etc
    public func get(forStopNumber stopNumber: Int) -> BusStop?
    {
        guard let stopLocation = self.locationRepository.findByStopNumber(stopNumber),
              let responseData = tryStrategies(stopNumber, stopLocation) else {
            return nil
        }
        
        return try? self.responseMapper.mapResponseToBusStop(
            withApiResponse: responseData, withStopNumber: stopNumber, withLocation: stopLocation.asCLLocation()
        )
    }
    
    /// Try strategies from the `DataRetrievalStrategyFactory` recursively until we run out of strategies to retieve data, then map
    ///
    /// - Parameters:
    ///   - stopNumber:       The bus stop number to try data retrieval for
    ///   - stopLocation:     The bus stop location to use in the creation of the `BusStop` entity
    ///   - fallbackStrategy: Optional internal parameter for recursive call - fallsback from previous strategy, if the next strategy exists
    ///
    /// - Returns: Either the data, or nil if none could be retrieved
    fileprivate func tryStrategies(_ stopNumber: Int, _ stopLocation: BusStopLocation, _ fallbackStrategy: DataRetrievalStrategy? = nil) -> [String: Any]?
    {
        guard let strategy = self.strategyFactory.getNextAvailableStrategy(fallbackFrom: fallbackStrategy) else {
            return nil
        }
        
        guard let responseData = try? await(strategy.retrieveData(forStopNumber: stopNumber)) else {
            return tryStrategies(stopNumber, stopLocation, strategy)
        }
        
        return responseData
    }
}
