//
//  ApiKeys.swift
//  GithubBusApp
//
//  Created by James Mallison on 18/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Foundation

/// Contains the Public / Private and API Keys required for `HmacDataRetrievalStrategy`
struct ApiCredentials
{
    /// Describes the environment for which the application will run (effectively chooses which api key to use)
    public enum Environment
    {
        case production
        case enterprise
        case development
    }

    /// Holds the Api Keys required by `SigningKeyRequest` and `SignedRequest` under `HmacDataRetrievalStrategy`
    ///
    /// - production: The production api key (used thus far)
    /// - enterprise: The enterprise api key (not used yet)
    /// - development: The development api key (not used yet)
    private enum ApiKeys: String
    {
        /// The production api key (used thus far)
        case production = "c4613ee9-7fa6-4705-8c94-1e3dc656bf3c"
        
        /// The enterprise api key (not used yet)
        case enterprise = "f3f46ba6-fa3b-4e8f-8a23-ed888f719b96"
        
        /// The development api key (not used yet)
        case development = "b337d221-0368-4214-83b7-91596200321f"
    }
    
    /// The environment used to decide which keys to use
    public let environment: Environment
    
    /// The same uuid must be used between the request to get the signing key, and the signed request afterwards
    private let uuidGenerator: CachingUuidGenerator
    
    /// The apiKey, dictated by the environment
    public var apiKey: String {
        get {
            switch self.environment {
                case .production:
                    return ApiKeys.production.rawValue
                case .enterprise:
                    return ApiKeys.enterprise.rawValue
                case .development:
                    return ApiKeys.development.rawValue
            }
        }
    }
    
    /// The same uuid must be used between the request to get the signing key, and the signed request afterwards
    public var uuid: String {
        get {
            return self.uuidGenerator.getCachedUuid().uuid
        }
    }
    
    /// Initialise a set of `ApiKeys`
    ///
    /// - Parameters:
    ///   - environment:   This decides what key will be returned by `.apiKey`
    ///   - uuidGenerator: The same uuid must be used between the request to get the signing key, and the signed request afterwards
    init(forEnvironment environment: Environment, withUuidGenerator uuidGenerator: CachingUuidGenerator)
    {
        self.environment   = environment
        self.uuidGenerator = uuidGenerator
    }
    
    /// Used in the case we get a 401 Unauthorized response code, in case they accidentally blocked out our uuid
    ///
    /// - Returns: The new uuid string
    public func getForceRefreshedUuid() -> String
    {
        return self.uuidGenerator.getCachedUuid(forceRegenerate: true).uuid
    }

    /// Public PEM key, base64 encoded
    public let publicKey = "MIIBCgKCAQEA6b+srAin09w5BltI1tlOn64r61rXFwSHUME4FGSTcXc9eOl5vFsmkjXO7XzhLbsm+mTqvCC/l+T7yQ/JjcyQgTcAWFXiYuqamkGkaDPYULHO67VKHqYoYP/OsJQcFjjmMriqcqbA8Q/pf7lP5KOWPfZrr9GykrO83vlRUXdORXeZob7lRBtMVjXLuOq39P0CDYxkACx1NQo9MJMlfRpxAcWpNPJpgAOWsuyhRlsbYgondt3KSlpBtxSeH3T43VUnUbjpXh4v883ZrWmLWq2v5YA7vAtggK/3/fn6g3M8o1F13CLYsq3rLCqnTKirxtdptrjPfsVApJsc/urJwCnaiwIDAQAB"
    
    /// Private PEM key, base64 encoded
    public let privateKey = "MIIEpAIBAAKCAQEAsecF2MhEcIT8t1TJXXSZuSNibJnEb2rtTyqnil+lf/VCMQhnb1nA9wViH67bnMxBEkFALnzOpOlv70bze6cj7Uiri2TkB+TRnAFD9tuZUMZ94k4GnrwkpiJhqiO0xgUiumwa/8brW35yin3DDKOaSXZtQRkSRKr5isyC4Yd0TVXa6dGJuVQoz0QGWFl4TCERqoy1ChzJtDUKgR2QQm/pzRZQF0gJTw8K6+eK2j6wzL25l1W15AJOQ0G/wWzby69HmWR834IBa+JFNYzaL4d2tT1P+m/F6zsL4slCbu4TpIzinOQajcEvV8jNleBwCuGKQF0w8QhWepln5oWMlejhdwIDAQABAoIBAHTxL964hoSQZq78hQFxzDrvD5vj2ESFPUl0+Hz1Mo1SYxhoNdX0Yev/FelNv/7qJTwiuFXWpN+ys2nOce8uh2dLBbizsVGfEEpEarCy2a1HTSidsaxWcKDkqN52ajZg2dtBhN3tnHigPhrbYIPGZ30y486O9Hs/CJo8pSwrJkBOvqXT9jOxdqX165TxfIw4+jqFAbLhzMlXjW3KAtU9aCR+b4485yqoOodWXeLw2B+JB6cSXt7aABibJiPqN9jPI9SWVZ9D6qt/swuPlGVRAfrOZN7UWyVL9S8gDjIFz6U0btn8xdQtpd7I/ZkvAtBL5NW5YePqSe9jyWFHZoP4H4ECgYEA30SP6yy4lV3uBiBUMj7VUyALmz0+UNAfW+Bzjjafw4hxnoiklTixSKmUq7fIHT67TNh7sL1ZNVo0NwvZ7R2S2Z7ytn8Vy40Un9KDgkpGCHxbBFmawa3lw7uLzf86bES2o+x3Ercvb7g4N5xg5tQnw/1rFwCTlsAkDc9UvElkUD8CgYEAy/vbk2EonJLfJJ32brY34ctmdCA7gkj8NVKbjWOFn4eus0nSiG/Wz57IW64kRHJh12A8cGSNPtTUTdA90Hl9qvMD8hRl4E2CNaZWNwRESX/DWWI3IFNZZy2gcqo/H+qgvSdM8Ux+e52TLKlqEmqxqYm+GG8ftq+V3UT3b0xiIMkCgYEAt1BC3jPUxgbeNLd8idifLGYGQYqyTIXlCXmrRxvAZznzF9hXUZG/tcpOoAMAUkq8XCbuv7lnsm+CqaOYZaA/f2CLJZ4Ilh0azvJ4OZSkFbmMvXCYqOcP3HpzGkqxfE2aq9KuHXa8gvz9Y2OJCF0u3TOIJtW5WDAgKhqOFx4nN98CgYByzfRd9V/bB5qJTFJHK002SrkGAKIdiKBSDoU3xVyOVdoQVCsm2PModTBE0TTeRRYmFqbNhvor87LtfJddvxLoZM/CrpJL9LOlKFH7su4QA9VZeDqYefCmbnqQLptKhk4jR3w5jpjdT+lmSI9HgD8vsTOJIvnRYu9Q0qEERhQwaQKBgQCcJ5zUEIkSy2NyIKmCT8ABCIZDnCfm0CkSjBcjQeO+z9FGbtdwnd6VrRlgcVSHweHmrKaJJ9IfK5BfnAswIFD6TQpk7M2pvIhjNEU/Uhpe29vTrl4EMRd9QwiuIASqbeFUXctYHcqzjJaxYek4x+0z2i62gET2Qtrl22Um3pTIuw=="
}

// MARK: - Extension: For use when the keys are base64encoded
extension ApiCredentials
{
    /// Get the base64decoded public key
    ///
    /// - Returns: The base64decoded public key
    public func publicKeyDecoded() -> String {
        return String(data: Data(base64Encoded: self.publicKey)!, encoding: .utf8)!
    }
    
    /// Get the base64decoded private key
    ///
    /// - Returns: The base64decoded private key
    public func privateKeyDecoded() -> String {
        return String(data: Data(base64Encoded: self.privateKey)!, encoding: .utf8)!
    }
}

