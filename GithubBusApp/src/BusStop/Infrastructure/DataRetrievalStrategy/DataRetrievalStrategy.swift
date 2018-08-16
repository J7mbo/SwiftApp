//
//  DataRetrievalStrategy.swift
//  GithubBusApp
//
//  Created by James Mallison on 18/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import PromiseKit

/// Generic 'could not retrieve data' error - we don't care why, we just couldn't get data, so
///
/// - Failure:      The failure here is only useful for dev logging - this will not be shown to the user
/// - Unauthorized: We've been locked out, might as well retry with a new identifier / credentials before failing
enum DataRetrievalError: Error
{
    case Failure(reason: String)
    case Unauthorized()
}

/// Represents an object capable of retrieving bus stop data from somewhere
protocol DataRetrievalStrategy
{
    /// Retrieve BusTimes data from anywhere
    ///
    /// - Parameter stopNumber: The bus stop number to retrieve data for
    ///
    /// - Returns: An `NSDictionary` containing the retrieved bus times data
    ///
    /// - Throws: `DataRetrievalError` - We couldn't get data, so handle this appropriately
    func retrieveData(forStopNumber stopNumber: Int) throws -> Promise<[String: Any]>
}
