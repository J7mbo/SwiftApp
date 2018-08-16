//
//  AuthenticatedRequest.swift
//  GithubBusApp
//
//  Created by James Mallison on 08/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import OrderedDictionary

/// The headers contain the request token required to make API requests, retrieved via `AuthTokenRequest` used in `ApiTokenDataRetrievalStrategy`
struct AuthenticatedRequest: NetworkRequestAdaptable
{
    /// This is the API endpoint to retrieve bus stop data from
    public var url: String = "XXXXXXX"
    
    /// This is a GET request
    var method: String = NetworkRequest.RequestMethod.get.rawValue
    
    /// The headers for this request must contain the api token in the Authorization header
    public var headers: [String: String] {
        return [
            "XXXXXX"
        ]
    }
    
    /// We should get json back
    public var responseType: String = NetworkRequest.ResponseType.json.rawValue
    
    /// The Api Token retrieved from an `AuthTokenRequest`
    private let apiToken: String
    
    /// Initialise an instance of an `AuthenticatedRequest`
    ///
    /// - Parameters:
    ///   - token:      The Api token retrieved from an `AuthTokenRequest`
    ///   - stopNumber: The bus stop number to retrieve bus time data for
    init(withApiToken token: String, withBusStopNumber stopNumber: Int)
    {
        self.apiToken = token
        self.url      = self.url.replacingOccurrences(of: "{busStopNumber}", with: String(stopNumber))
    }
    
    /// Provides any parameters for the request body (POST) or query parameters (GET)
    ///
    /// - Returns: An empty dictionary in this case, because this request does not need any parameters
    public func getParameters() -> MutableOrderedDictionary<NSString, NSString>
    {
        return [:]
    }
}
