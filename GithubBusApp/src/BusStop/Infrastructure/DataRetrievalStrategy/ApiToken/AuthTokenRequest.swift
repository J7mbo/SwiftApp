//
//  AuthTokenRequest.swift
//  GithubBusApp
//
//  Created by James Mallison on 08/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import OrderedDictionary

/// We retrieve the authentication token by making a request to the site and parsing the HTML to retrieve the JS token variable
struct AuthTokenRequest: NetworkRequestAdaptable
{
    /// The regex used to parse the token form the HTML output (stored as "window.XXXXXX")
    public let tokenMatchRegex: String = "XXXXXX"

    /// The base url which other urls will be appended onto
    fileprivate var baseUrl: String = "XXXXXX"
    
    /// Each url must provide the ability to retrieve an authentication token (and this can be verified manually), we choose a random one
    fileprivate var urls: [String] = [
        "XXXXXX"
    ]
    
    /// A computed randomized url as we don't always want to hit the same endpoint to get the token
    var url: String {
        return createFullUrlFromBaseUrlAnd(url: getRandomUrl())
    }
    
    /// This is a GET request
    var method: String = NetworkRequest.RequestMethod.get.rawValue
    
    /// We don't care about any specific headers for this request
    var headers: [String : String] = [:]
    
    /// We're getting HTML back here, so we just want a string
    var responseType: String = NetworkRequest.ResponseType.string.rawValue
    
    /// Usually the parameters for the GET / POST request
    ///
    /// - Returns: An empty dictionary as we don't need any parameters here
    func getParameters() -> MutableOrderedDictionary<NSString, NSString> {
        return [:]
    }
    
    /// Gets a random url from our internal set of urls
    ///
    /// - Returns: A random url (uses an extension to Array to get a randomized one)
    private func getRandomUrl() -> String {
        return urls.getRandomElementWithCount(1)[0] as! String
    }
    
    /// Concatenates a string to the end of our base url
    ///
    /// - Parameter string: The base url
    ///
    /// - Returns: The base url concatenated with the string provided
    private func createFullUrlFromBaseUrlAnd(url string: String) -> String {
        return baseUrl + string
    }
}
