//
//  NetworkRequestAdaptable.swift
//  GithubBusApp
//
//  Created by James Mallison on 25/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import OrderedDictionary

/// Defines a protocol which, if implemented, means the implementing object can easily be converted to a `NetworkRequest` object
protocol NetworkRequestAdaptable
{
    /// You should make sure that this is a valid url as used by `URL`
    var url: String { get }
    
    /// Must be one of `NetworkRequest.RequestMethod`
    var method: String { get }
    
    /// The headers you want to use for the request as key-value pairs
    var headers: [String: String] { get }
    
    /// Must be one of `NetworkRequest.ResponseType`
    var responseType: String { get }
    
    /// Any parameters to be added to the request
    ///
    /// - Important: Use `MutableOrderedDictionary` to ensure all properties are in the same order as provided within the dictionary
    ///
    /// - Returns: The parameters, regardless of whether GET / POST (they are converted appropriately for the request)
    func getParameters() -> MutableOrderedDictionary<NSString, NSString>
}
