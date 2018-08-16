//
//  UuidGenerator.swift
//  GithubBusApp
//
//  Created by James Mallison on 18/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Foundation

/// Responsible for generating a UUID used by `HmacDataRetrievalStrategy`
/// Take a look at `UuidGenerator.UuidFormat` for the format that the Hmac strategy requires to generate Uuid
struct UuidGenerator
{
    /// The exact format required for the full generated UUID
    fileprivate static let UuidFormat: String = "{PLATFORM}-{UUID}"
    
    /// Contains the platforms hardcoded in the Android SDK
    fileprivate let platforms: [String: String] = [
        "ios": "IOS",
        "android": "AND"
    ]

    /// Generate a random UUID for either Android or iOS devices
    ///
    /// - Returns: A random UUID for either Android or iOS devices
    public func generate() -> String
    {
        return formatUuid(platform: chooseRandomPlatform(), uuid: createRandomUuidString(), format: UuidGenerator.UuidFormat)
    }
    
    /// Choose one of `platforms` values pseudo-randomly
    private func chooseRandomPlatform() -> String
    {
        return Array(platforms.values)[Int(arc4random_uniform(UInt32(platforms.count)))]
    }
    
    /// Create a UUID string using `UUID.init()`
    private func createRandomUuidString() -> String
    {
        return UUID.init().uuidString
    }
    
    /// Create the uuid string according to the `UuidFormat` format
    ///
    /// - Parameters:
    ///   - platform: A randomly chosen platform
    ///   - uuid: A randomly generated unique device identifier
    ///   - format: The format
    /// - Returns: The formatted uuid string
    private func formatUuid(platform: String, uuid: String, format: String) -> String
    {
        return format.replacingOccurrences(of: "{PLATFORM}", with: platform).replacingOccurrences(of: "{UUID}", with: uuid)
    }
}
