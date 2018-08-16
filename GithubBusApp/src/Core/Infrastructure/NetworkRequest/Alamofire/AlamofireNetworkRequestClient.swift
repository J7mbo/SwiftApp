//
//  AlamofireNetworkRequestClient.swift
//  GithubBusApp
//
//  Created by James Mallison on 24/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import PromiseKit
import AwaitKit
import Alamofire

class AlamofireNetworkRequestClient: NSObject, NetworkRequestClient
{
    /// Alamofire session manager
    ///
    /// - Parameter sessionManager: The alamofire session manager
    private let sessionManager: SessionManager
    
    /// Creates a `URLRequest` object from a dev-provided `NetworkRequest` object
    private let requestFactory: UrlRequestFactory
    
    /// It is recommend you initialise this object via `Alamofire.SessionManager.default`, which provides reasonable default behaviour
    ///
    /// - Parameters:
    ///   - session:           The object to make the request (via a call to dataTask()) with
    ///   - urlRequestFactory: The request factory to transforms `NetworkRequests` to `URLRequests` with
    init(withSessionManager sessionManager: SessionManager, withRequestFactory requestFactory: UrlRequestFactory) {
        self.sessionManager = sessionManager
        self.requestFactory = requestFactory
    }
    
    /// Performs an asynchronous HTTP request
    ///
    /// - Parameter request: The request to make
    ///
    /// - Returns: Either the string response or json response depending on the `NetworkRequest` configuration
    func request(withRequest request: NetworkRequest) throws -> Promise<NetworkResponse> {
        return Promise<NetworkResponse> { fulfill, reject in
            /** The flatMap and reduce turn [[String: String]] into [String: String] which is what we want for alamofire's parameters **/
            let alamofireParameters: [String: String] = request.parameters.map { parameter -> [String: String] in
                return [parameter.key: parameter.value]
            }.flatMap {
                $0
            }.reduce([String:String]()) { (dict, tuple) in
                var nextDict = dict
                
                nextDict.updateValue(tuple.1, forKey: tuple.0)
                
                return nextDict
            }

            self.sessionManager.request(request.url, method: .get, parameters: alamofireParameters as [String: String]).responseString { response in
                print("HERETWO")
                if let error = response.error {
                    return reject(error)
                }
                
                return fulfill(NetworkResponse(statusCode: 1, string: response.result.value!))
            }
        }
    }
    
    func cancelRequest(forUrl url: URL) -> Promise<Bool> {
        return Promise { fulfill, reject in
            // @todo: DO THIS
            fulfill(true)
        }
    }
}
