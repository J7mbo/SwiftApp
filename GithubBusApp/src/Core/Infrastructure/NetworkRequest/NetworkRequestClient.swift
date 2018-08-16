//
//  NetworkRequest.swift
//  GithubBusApp
//
//  Created by James Mallison on 20/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import PromiseKit

/// Contains the different types of errors that could occur when a `NetworkRequestClient` failed to perform a request for some reason
///
/// - httpError: The raw error
enum NetworkRequestError {
    case httpError(error: Error)
}

/// A HttpClient. Instead of directly using `Alamofire`, or `URLSession` for example, just call the methods on this abstraction and everything else will be taken care of. Uses `PromiseKit` instead of other fuckery everywhere
protocol NetworkRequestClient
{
    /// Perform a HTTP request
    ///
    /// - Parameter request: An instance of `NetworkRequest`
    ///
    /// - Throws: `NetworkRequestError` when something goes wrong
    ///
    /// - Returns: A promise to be resolved as a `NetworkResponse`: always containing the response as a string, optionally containing a JSON decoded dictionary depending on the `NetworkRequest.ResponseType` in the `NetworkRequest`
    func request(withRequest request: NetworkRequest) throws -> Promise<NetworkResponse>
    
    /// Attempts to cancel an in-progress request, identified by the `URL`
    ///
    /// - Important: If multiple requests to the same URL are encountered, only the first will be cancelled
    ///
    /// - Parameter url: The URL to cancel
    ///
    /// - Returns: A promise resolving to a boolean on whether or not the request cancellation succeeded - if false, the request already completed
    func cancelRequest(forUrl url: URL) -> Promise<Bool>
}
