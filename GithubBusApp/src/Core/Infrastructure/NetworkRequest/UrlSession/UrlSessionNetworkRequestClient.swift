//
//  UrlSessionNetworkRequest.swift
//  GithubBusApp
//
//  Created by James Mallison on 21/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import PromiseKit

/// A HttpClient that uses `URLSession`. Uses `PromiseKit` instead of async fuckery everywhere
class UrlSessionNetworkRequestClient: NetworkRequestClient
{
    /// The object to make the request (via a call to dataTask()) with
    private let urlSession: URLSession
    
    /// Creates a `URLRequest` object from a dev-provided `NetworkRequest` object
    private let urlRequestFactory: UrlRequestFactory
    
    /// It is recommend you initialise this object via `URLSession.shared()`, which provides a shared singleton session object with resonable default behaviour
    ///
    /// - Parameters:
    ///   - session:           The object to make the request (via a call to dataTask()) with
    ///   - urlRequestFactory: The request factory to transforms `NetworkRequests` to `URLRequests` with
    init(withURLSession session: URLSession, withUrlRequestFactory urlRequestFactory: UrlRequestFactory)
    {
        self.urlSession        = session
        self.urlRequestFactory = urlRequestFactory
    }
    
    /// Performs an asynchronous HTTP request
    ///
    /// - Parameter request: The request to make
    ///
    /// - Returns: Either the string response or json response depending on the `NetworkRequest` configuration
    public func request(withRequest request: NetworkRequest) throws -> Promise<NetworkResponse>
    {
        return Promise<NetworkResponse> { fulfill, reject in
            let url: URLRequest = self.urlRequestFactory.create(fromNetworkRequest: request, andEncoding: false) as URLRequest

            self.urlSession.dataTask(with: url) { (data, response, error) in
                if (error != nil) {
                    return reject(error!)
                }
                
                let dataString = String(data: data ?? Data(), encoding: String.Encoding.utf8)
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                
                return fulfill(NetworkResponse(statusCode: statusCode, string: dataString))
            }.resume()
        }
    }

    /// Attempts to cancel an in-progress request, identified by the `URL`
    ///
    /// - Important: If multiple requests to the same URL are encountered, only the first one is cancelled
    ///
    /// - Parameter url: The URL to cancel
    ///
    /// - Returns: A promise resolving to a boolean on whether or not the request cancellation succeeded - if false, the request already completed
    public func cancelRequest(forUrl url: URL) -> Promise<Bool>
    {
        return Promise { resolve, _ in
            self.urlSession.getTasksWithCompletionHandler { (dataTasks, _, _) in
                for dataTask in dataTasks {
                    if dataTask.originalRequest?.url?.absoluteURL == url.absoluteURL {
                        dataTask.cancel()
                        
                        return resolve(true)
                    }
                }
                
                return resolve(false)
            }
        }
    }
}
