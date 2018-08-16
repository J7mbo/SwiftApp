//
//  HmacDataRetrievalStrategy.swift
//  GithubBusApp
//
//  Created by James Mallison on 18/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Alamofire
import PromiseKit
import AwaitKit
import SwiftyRSA

/// Retrieves data using Public / Private key + HMAC - this is likely the first shot at retrieving the bus stop data, and if it fails we try and re-authenticated else fallback to another strategy.
struct HmacDataRetrievalStrategy: DataRetrievalStrategy
{
    /// The HTTP client to retrieve the data with
    private let client: NetworkRequestClient
    
    /// We need the private key from `ApiKeys` to decrypt the signing key from the server
    private let apiCredentials: ApiCredentials
    
    /// Initialise a `HmacDataRetrievalStrategy`
    ///
    /// - Parameters:
    ///   - client:         The HTTP Client to retrieve the data with
    ///   - apiCredentials: The API Credentials containing api keys, uuid etc
    init(client: NetworkRequestClient, apiCredentials: ApiCredentials) {
        self.client         = client
        self.apiCredentials = apiCredentials
    }
    
    /// Retrieve BusTimes data via Public / Private key + HMAC
    ///
    /// - Parameter stopNumber: The bus stop number to retrieve data for
    ///
    /// - Returns: An `NSDictionary` containing the retrieved bus times data
    ///
    /// - Throws: `DataRetrievalError` - We couldn't get data, so handle this appropriately
    public func retrieveData(forStopNumber stopNumber: Int) throws -> Promise<[String: Any]>
    {
        return Promise { resolve, reject in
            do {
                let deviceUuid = self.apiCredentials.uuid
                
                let encryptedSigningKey: String = try await(self.makeRequestForSigningKey(withDeviceUuid: deviceUuid))
                let decryptedSigningKey: String = try self.decryptSigningKey(encryptedSigningKey)
                
                resolve(try await(self.makeSignedRequest(withUuid: deviceUuid, withSigningKey: decryptedSigningKey, forStopNumber: stopNumber)))
            } catch {
                return reject(DataRetrievalError.Failure(reason: "Failed decrypting the key from the server"))
            }
        }
    }
    
    /// Step 1 of 3 - Retrieve the signing key from the server
    ///
    /// - Returns: A promise resolving to a single string containing the signing key
    private func makeRequestForSigningKey(withDeviceUuid uuid: String) -> Promise<String>
    {
        return Promise { resolve, reject in
            let signingRequest = SigningKeyRequest(uuid: uuid, withApiCredentials: self.apiCredentials)
            let networkRequest = NetworkRequest.createFrom(networkRequestAdaptable: signingRequest)
            
            guard let response = try? await(self.client.request(withRequest: networkRequest)) else {
                return reject(DataRetrievalError.Failure(reason: "Could not get response from request, AwaitKit failed here"))
            }
            
            guard let json = response.asJson else {
                return reject(DataRetrievalError.Failure(reason: "Expected json response when retrieving HMAC data, but couldn't convert to json"))
            }
            
            guard let signingKey = json["key"] as? String else {
                return reject(DataRetrievalError.Failure(reason: "Got a json response when retrieving HMAC data, but it did not contain the signing key"))
            }
            
            return resolve(signingKey)
        }
    }
    
    /// Step 2 of 3 - The signing key must be decrypted with the private key
    ///
    /// - Parameter encryptedSigningKey: The encrypted signing key from `makeRequestForSigningKey()`
    ///
    /// - Returns: The decrypted signing key
    private func decryptSigningKey(_ encryptedSigningKey: String) throws -> String
    {
        /** This should always pass, because it's our private key - dev error if it throws **/
        let privateKey = try! PrivateKey(base64Encoded: self.apiCredentials.privateKey)
        
        /** This on the other hand... we might get back a bullshit key from the server, can't ! this one guys! **/
        let encryptedMessage = try EncryptedMessage(base64Encoded: encryptedSigningKey)
        let clearMessage     = try encryptedMessage.decrypted(with: privateKey, padding: .PKCS1)

        return try clearMessage.string(encoding: .utf8)
    }
    
    
    /// Step 3 of 3 - Perform a signed request for the bus stop data with the signing key
    ///
    /// - Parameters:
    ///   - uuid:       The decrypted signing key from `decryptSigningKey()`
    ///   - signingKey: The decrypted signing key from `decryptSigningKey()`
    ///   - stopNumber: The bus stop number to append to the url to retrieve data for
    ///
    /// - Returns: A promise resolving to a dictionary converted from json from the server, this is it!!
    private func makeSignedRequest(withUuid uuid: String, withSigningKey signingKey: String, forStopNumber stopNumber: Int) throws -> Promise<[String: Any]>
    {
        return Promise { resolve, reject in
            let signedRequest = SignedRequest(withApiCredentials: self.apiCredentials, withUuid: uuid, withSigningKey: signingKey, forStopNumber: stopNumber)
            
            let networkRequest = NetworkRequest.createFrom(networkRequestAdaptable: signedRequest)
            
            let response = try? await(self.client.request(withRequest: networkRequest))
            
            if response?.statusCode == 401 {
                return reject(DataRetrievalError.Unauthorized())
            }
            
            guard let jsonData = response?.asJson else {
                return reject(DataRetrievalError.Failure(reason: "Got data from server for signed request, but it wasn't json"))
            }
            
            return resolve(jsonData)
        }
    }
}
