//
//  NetworkRequest.swift
//  GithubBusApp
//
//  Created by James Mallison on 21/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Foundation

/// Contains the contents of a generic Http Request - Used with `NetworkRequestClient`
struct NetworkRequest
{
    /// Validation errors caused only on instantiation of an invalid `NetworkRequest` object that are nothing to do with an actual Request being performed
    ///
    /// - UrlError: When an invalid url is provided to `init`
    public enum InitError: Error
    {
        case UrlError(url: String)
    }
    
    /// The HTTP method to be used for the `NetworkRequest`
    ///
    /// - get: A GET request
    /// - post: A POST request
    public enum RequestMethod: String
    {
        case get
        case post
    }
    
    /// Any request parameters (if GET, these will be encoded and set as ?key=value in the URL, otherwise as POST will be in the POST body)
    public struct RequestParameter
    {
        let key: String
        let value: String
    }
    
    /// Any request headers as key-value-pairs
    public struct RequestHeader
    {
        let key: String
        let value: String
    }
    
    /// The response type; setting this dictates whether or not we attempt to json decode the response
    ///
    /// - string: Return the plain response as a string
    /// - json: Return the response as an `NSDictionary`, decoded from json
    public enum ResponseType: String
    {
        case string
        case json
    }
    
    /// Any request parameters that will be sent for this request - these can be added after initialisation
    public var parameters: [RequestParameter] = []
    
    /// The url that the request will be sent to
    private(set) var url: URL
    
    /// The http method that will be used for the request
    private(set) var method: RequestMethod = .get

    /// The headers as an array of KVPs that will be used for the request
    private(set) var headers: [RequestHeader] = []
    
    /// The response type, effectively deciding whether or not the response will be attempted to be json decoded
    private(set) var responseType: ResponseType = .string
    
    /// The simplest way to initialise: with a url string. The request method defaults to GET, the response type defaults to string and there are no added headers
    ///
    /// - Parameter url: The url string
    ///
    /// - Throws: `InitError.UrlError` if the `url` parameter is not a valid url string
    init(withUrl url: String) throws
    {
        self.url = try NetworkRequest.ensureValidUrl(url: url)
    }
    
    /// Initialise with a url string and request method. The response type defaults to string
    ///
    /// - Parameter url:    The url string
    /// - Parameter method: The request method, a case from the `RequestMethod` enum
    ///
    /// - Throws: `InitError.UrlError` if the `url` parameter is not a valid url string
    init(withUrl url: String, andMethod method: RequestMethod) throws
    {
        self.url    = try NetworkRequest.ensureValidUrl(url: url)
        self.method = method
        
        self.addContentTypeIfPostRequest(method: method)
    }
    
    /// Initialise with a url string, a request method and headers. The response type defaults to string
    ///
    /// - Parameter url:     The url string
    /// - Parameter method:  The request method, a case from the `RequestMethod` enum
    /// - Parameter headers: An array of key-value-pairs to add as request headers
    ///
    /// - Throws: `InitError.UrlError` if the `url` parameter is not a valid url string
    init(withUrl url: String, andMethod method: RequestMethod, andHeaders headers: [RequestHeader]) throws
    {
        self.url     = try NetworkRequest.ensureValidUrl(url: url)
        self.method  = method
        self.headers = headers
        
        self.addContentTypeIfPostRequest(method: method)
    }
    
    
    /// Initialise with a url string, a request method and a response type
    ///
    /// - Parameter url:          The url string
    /// - Parameter method:       The request method, a case from the `RequestMethod` enum
    /// - Parameter responseType: The response type, a case from the `ResponseType` enum, which dictates whether or not to attempt to decode the response as json
    ///
    ///  - Throws: `InitError.UrlError` if the `url` parameter is not a valid url string
    init(withUrl url: String, andMethod method: RequestMethod, andResponseType responseType: ResponseType) throws
    {
        self.url          = try NetworkRequest.ensureValidUrl(url: url)
        self.method       = method
        self.responseType = responseType
        
        self.addContentTypeIfPostRequest(method: method)
    }
    
    /// Initialise with a url string, a request method, headers and a response type
    ///
    /// - Parameter url:          The url string
    /// - Parameter method:       The request method, a case from the `RequestMethod` enum
    /// - Parameter headers:      An array of key-value-pairs to add as request headers
    /// - Parameter responseType: The response type, a case from the `ResponseType` enum, which dictates whether or not to attempt to decode the response as json
    ///
    ///  - Throws: `InitError.UrlError` if the `url` parameter is not a valid url string
    init(withUrl url: String, andMethod method: RequestMethod, andHeaders headers: [RequestHeader], andResponseType responseType: ResponseType) throws
    {
        self.url          = try NetworkRequest.ensureValidUrl(url: url)
        self.method       = method
        self.headers      = headers
        self.responseType = responseType
        
        self.addContentTypeIfPostRequest(method: method)
    }
    
    /// Add request parameters to the request
    ///
    /// - Parameter parameters: Any parameters to be added to the request
    mutating public func addParameters(parameters: [RequestParameter])
    {
        for parameter in parameters {
            self.parameters.append(parameter)
        }
    }
    
    /// Validates a url string and returns a `URL` object
    ///
    /// - Parameter url: The url string to validate
    /// - Returns: A URL object
    /// - Throws: An `InitError.urlError` on failure to create a URL
    private static func ensureValidUrl(url: String) throws -> URL
    {
        guard let urlObject = URL(string: url) else {
            throw InitError.UrlError(url: url)
        }
        
        return urlObject
    }
    
    /// If this is a POST request, then add the urlencoded content type so we can easily specify parameters as we would with a GET request.. ?x=y&z=a
    ///
    /// - Parameter method: The `RequestMethod` to check
    mutating private func addContentTypeIfPostRequest(method: RequestMethod) -> Void
    {
        if method == .post {
            self.headers.append(RequestHeader(key: "Content-Type", value: "application/x-www-form-urlencoded"))
        }
    }
}

// MARK: - Extension: Adds NetworkRequestAdaptable support
extension NetworkRequest
{
    /// Create an instance of `NetworkRequest` from the configuration contained within a `NetworkRequestAdaptable`
    ///
    /// - Parameter request: The pre-configued signing-key request
    ///
    /// - Returns: An instance of `NetworkRequest` ready to be used with `NetworkRequestClient`
    public static func createFrom(networkRequestAdaptable request: NetworkRequestAdaptable) -> NetworkRequest
    {
        var headers: [NetworkRequest.RequestHeader] = []
        
        for (headerKey, headerValue) in request.headers {
            headers.append(self.RequestHeader(key: headerKey, value: headerValue))
        }
        
        var networkRequest = try! self.init(
            withUrl: request.url,
            andMethod: self.RequestMethod(rawValue: request.method)!,
            andHeaders: headers,
            andResponseType: self.ResponseType(rawValue: request.responseType)!
        )

        for (paramKey, paramValue) in request.getParameters() {
            networkRequest.addParameters(parameters: [self.RequestParameter(key: String(describing: paramKey), value: String(describing: paramValue))])
        }
        
        return networkRequest
    }
}
