//
//  SigningKeyRequest.swift
//  GithubBusApp
//
//  Created by James Mallison on 19/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import SwiftyRSA
import OrderedDictionary

/// The request to get the signing key used for the `HmacDataRetrievalStrategy`
struct SigningKeyRequest: NetworkRequestAdaptable
{
    /// The request url
    public let url: String = "XXXXXX"
    
    /// The request method
    public let method = "get"
 
    /// The headers used for the request
    public let headers: [String: String] = [
        "XXXXXX"
    ]
    
    /// The type of data we're expecting back from the server
    public let responseType = "json"
    
    /// We need a uuid to make the request for a signing key
    private var uuid: String

    /// We need our api key and public key out of this
    private var apiCredentials: ApiCredentials

    /// Initialise a `SigningKeyRequest` object
    ///
    /// - Parameters:
    ///   - uuidGenerator: ...and the uuid for the signing key request
    ///   - apiCredentials: We pull the public key out of this for signing
    init(uuid: String, withApiCredentials apiCredentials: ApiCredentials)
    {
        self.uuid           = uuid
        self.apiCredentials = apiCredentials
    }

    /// Get the request parameters - as this is a GET request these should be appended onto the url and NOT in the body
    ///
    /// - Returns: The request parameters
    public func getParameters() -> MutableOrderedDictionary<NSString, NSString>
    {
        var parameters: MutableOrderedDictionary<NSString, NSString>
        
        parameters = [
            "XXXXXX"
        ]
        
        return parameters
    }
    
    /// The uuid should be encrypted with our Public Key and encoded in base64 for the signing key request payload
    private func getEncryptedUuid() -> String
    {
        let publicKey = try! PublicKey(base64Encoded: self.apiCredentials.publicKey)
        
        return try! ClearMessage(string: self.uuid, using: .utf8).encrypted(with: publicKey, padding: .PKCS1).base64String
    }
}
