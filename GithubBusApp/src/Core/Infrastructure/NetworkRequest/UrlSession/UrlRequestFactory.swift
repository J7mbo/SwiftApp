//
//  UrlRequestFactory.swift
//  GithubBusApp
//
//  Created by James Mallison on 21/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Foundation

/// Responsible for creating a `URLRequest` object, initially from our own internal `NetworkRequest` object
struct UrlRequestFactory
{
    /// Create an `NSMutableURLRequest` from a `NetworkRequest`
    ///
    /// - Parameters:
    ///   - networkRequest: The `NetworkRequest`
    ///   - shouldEncode: Defaults to true, set to false to avoid encoding GET parameters
    ///
    /// - Returns: The foundation request object
    public func create(fromNetworkRequest networkRequest: NetworkRequest, andEncoding shouldEncode: Bool = true) -> NSMutableURLRequest
    {
        let request = NSMutableURLRequest(url: networkRequest.url)
        
        setHttpMethod(request, networkRequest.method)
        addHeaders(request, networkRequest.headers)
        addBody(request, networkRequest.parameters, shouldEncode)
        
        return request
    }
    
    /// Sets the HTTP method on the request object
    ///
    /// - Parameters:
    ///   - request: The foundation request object
    ///   - method: Our network request method
    private func setHttpMethod(_ request: NSMutableURLRequest, _ method: NetworkRequest.RequestMethod) -> Void
    {
        request.httpMethod = String(describing: method)
    }

    /// Adds headers to the request object
    ///
    /// - Parameters:
    ///   - request: The foundation request object
    ///   - headers: Our network request headers
    private func addHeaders(_ request: NSMutableURLRequest, _ headers: [NetworkRequest.RequestHeader]) -> Void
    {
        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
    }
    
    /// Adds query parameters to the url if a GET request, else adds http body
    ///
    /// - Important: The `NetworkRequest` should have the `Content-Type: application/x-www-form-urlencoded` header set within it
    ///
    /// - Parameters:
    ///   - request: The foundation request object
    ///   - parameters: Our network request parameters
    ///   - encode: Whether or not to encode the parameters in the url (useful for GET requests)
    private func addBody(_ request: NSMutableURLRequest, _ parameters: [NetworkRequest.RequestParameter], _ encode: Bool) -> Void
    {
        guard let requestUrl = request.url, var componentisedUrl = URLComponents(string: requestUrl.absoluteURL.absoluteString) else {
            return
        }
        
        encodeUrlIfRequired(encode, &componentisedUrl, parameters)

        if (request.httpMethod == "GET") {
            /** Apple acknowledges that we have to encode + with %2B manually: https://stackoverflow.com/a/27724627/736809 **/
            componentisedUrl.percentEncodedQuery = componentisedUrl.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            
            return request.url = componentisedUrl.url
        }
        
        if (request.httpMethod == "POST") {
            /** When retrieving the query, we lose the url encoding, so we have to re-encode it **/
            guard let percentEncodedQueryString = componentisedUrl.query?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return
            }
            
            return request.httpBody = percentEncodedQueryString.data(using: String.Encoding.utf8)
        }
    }
    
    /// Encodes the parameters for the request if required
    ///
    /// - Parameters:
    ///   - encode: Whether to encode or not
    ///   - componentisedUrl: The url components to update
    ///   - parameters: The parameters to encode or not
    fileprivate func encodeUrlIfRequired(_ encode: Bool, _ componentisedUrl: inout URLComponents, _ parameters: [NetworkRequest.RequestParameter]) {
        if (encode == true) {
            componentisedUrl.queryItems = parameters.map { parameter -> URLQueryItem in
                return URLQueryItem(name: parameter.key, value: parameter.value)
            }
        } else {
            var query: String = ""
            
            for parameter in parameters {
                query = query + (parameter.key + "=" + parameter.value)
                
                if parameter.key != parameters.last!.key {
                    query += "&"
                }
            }
            
            componentisedUrl.query = query
        }
    }
}
