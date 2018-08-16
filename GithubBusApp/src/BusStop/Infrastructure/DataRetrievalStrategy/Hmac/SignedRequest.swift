//
//  SignedRequest.swift
//  GithubBusApp
//
//  Created by James Mallison on 24/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import OrderedDictionary
import IDZSwiftCommonCrypto
import CryptoSwift

struct SignedRequest: NetworkRequestAdaptable
{
    /// The api endpoint
    public var url: String = "XXXXXX"
    
    /// The request method
    public let method: String = "get"
    
    /// The headers used for the request
    public let headers: [String: String] = [
        "XXXXXX"
    ]
    
    public let responseType: String = "json"
    
    /// We need the api key from this which must be provided in the URL
    private let apiCredentials: ApiCredentials
    
    /// Device uuid must be provided in the URL
    private let uuid: String
    
    /// The decrypted signing key created by the `SigningKeyRequest`
    private let signingKey: String
    
    /// Provide the stop number so we know which request endpoint to target
    private let stopNumber: Int
    
    /// Initialise a `SignedRequest`
    ///
    /// - Parameters:
    ///   - apiCredentials: Contains the API Key that must be provided in the request
    ///   - uuid:           The device UUID that must be provided in the request
    ///   - signingKey:     The decrypted signing key retrieved by `SigningKeyRequest`
    ///   - stopNumber:     The bus stop number to make get data for
    init(withApiCredentials apiCredentials: ApiCredentials, withUuid uuid: String, withSigningKey signingKey: String, forStopNumber stopNumber: Int)
    {
        self.apiCredentials = apiCredentials
        self.uuid           = uuid
        self.signingKey     = signingKey
        self.stopNumber     = stopNumber
        
        self.url += String(stopNumber)
    }
    
    /// Get the parameters for the request
    ///
    /// - Returns: The parameters for the request - importantly this contains a 'signature' key
    public func getParameters() -> MutableOrderedDictionary<NSString, NSString> {
        let timeStamp = self.createTimeStamp()
        let signature = self.createSignature(timeStamp: timeStamp)
        
        return [
            "XXXXXX"
        ]
    }
    
    /// Create the signature that must in an exact json format (with spaces etc) for the request
    ///
    /// - Parameter timeStamp: The timestamp - make sure this is the same one used for `createPar
    ///
    /// - Returns: The signature string - this could be empty if the signing key was incorrect
    private func createSignature(timeStamp: String) -> String
    {
        let orderedSignatureParameters: MutableOrderedDictionary<NSString, NSString> = [
            "XXXXXX"
        ]
        
        /** We know this will work, because the parameters were created above!! **/
        var jsonString = String(data: try! JSONSerialization.data(withJSONObject: orderedSignatureParameters), encoding: .utf8)!
        
        /** The signature MUST have spaces after the : in the json, and after the comma ... it must be an exact format for their end **/
        jsonString = jsonString.replacingOccurrences(of: ":", with: ": ").replacingOccurrences(of: ",", with: ", ")
        
        /** This may not work because the signingKey has been retrieved from the server, so return an empty string and fail further up the chain **/
        return IDZSwiftCommonCrypto.HMAC(algorithm: .sha1, key: self.signingKey).update(string: jsonString)?.final().toHexString() ?? ""
    }
    
    /// Create the timestamp for the request payload
    ///
    /// - Returns: The timestamp for the request
    private func createTimeStamp() -> String
    {
        return String(Int64(NSDate().timeIntervalSince1970 * 1000.0))
    }
}
