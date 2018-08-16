//
//  ApiTokenDataRetrievalStrategy.swift
//  GithubBusApp
//
//  Created by James Mallison on 08/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import PromiseKit
import AwaitKit

/// Retrieves data by utilising an api token to make authenticated requests - the token tends to last for a short period of time
struct ApiTokenDataRetrievalStrategy: DataRetrievalStrategy
{
    /// The HTTP client to retrieve the data with
    private let httpClient: NetworkRequestClient
    
    /// Initialise an instance of `ApiTokenDataRetrievalStrategy`
    ///
    /// - Parameter httpClient: The http client to make requests with
    init(withNetworkRequestClient httpClient: NetworkRequestClient)
    {
        self.httpClient = httpClient
    }
    
    /// Retrieve bus stop data from the open API endpoint
    ///
    /// - Parameter stopNumber: The bus stop number to retrieve data for
    ///
    /// - Returns: Hopefully the dictionary of bus stop data from the API endpoint
    ///
    /// - Throws: `DataRetrievalError.Failure` when the failure happens - typically just contains a dev message, not for the user
    public func retrieveData(forStopNumber stopNumber: Int) throws -> Promise<[String : Any]> {
        return Promise { resolve, reject in
            guard let apiToken = try await(self.makeRequestForApiToken()) else {
                return reject(DataRetrievalError.Failure(reason: "Could not retrieve API token - the regex failed or the token no longer exists"))
            }

            guard let data = try await(self.makeAuthenticatedRequest(withApiToken: apiToken, forStopNumber: stopNumber)) else {
                return reject(DataRetrievalError.Failure(reason: "Request with API token failed - the token retrieval worked, but the request did not"))
            }
            
            return resolve(data)
        }
    }
    
    /// Performs a request to retrieve the API token from the website by parsing the HTML
    ///
    /// - Returns: A promise resolving to a string or nil containing the api token
    private func makeRequestForApiToken() -> Promise<String?>
    {
        return Promise { resolve, reject in
            let authRequest: AuthTokenRequest  = AuthTokenRequest()
            let networkRequest: NetworkRequest = NetworkRequest.createFrom(networkRequestAdaptable: authRequest)
            
            guard let response = try? await(self.httpClient.request(withRequest: networkRequest)).string else {
                return resolve(nil)
            }
            
            guard let match: Range<String.Index> = response!.range(of: authRequest.tokenMatchRegex, options: .regularExpression) else {
                return resolve(nil)
            }

            resolve(String(response![match]))
        }
    }
    
    /// Perform an authenticated request with the token retrieved from `makeRequestForApiToken()` and the bus stop number
    ///
    /// - Parameters:
    ///   - token:      The token retrieved from `makeRequestForApiToken()`
    ///   - stopNumber: The bus stop number
    ///
    /// - Returns: A promise resolving to a dictionary containing the parsed json response from the API
    private func makeAuthenticatedRequest(withApiToken token: String, forStopNumber stopNumber: Int) -> Promise<[String: Any]?>
    {
        return Promise { resolve, reject in
            let authRequest: AuthenticatedRequest = AuthenticatedRequest(withApiToken: token, withBusStopNumber: stopNumber)
            let networkRequest: NetworkRequest    = NetworkRequest.createFrom(networkRequestAdaptable: authRequest)
            
            guard let response = try? await(self.httpClient.request(withRequest: networkRequest)).asJson else {
                return resolve(nil)
            }
            
            return resolve(response!)
        }
    }
}
