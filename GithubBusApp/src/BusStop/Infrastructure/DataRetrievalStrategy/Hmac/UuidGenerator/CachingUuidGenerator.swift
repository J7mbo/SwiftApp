//
//  CachingUuidGenerator.swift
//  GithubBusApp
//
//  Created by James Mallison on 25/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Foundation
import AwaitKit

/// Decorates the `UUIDGenerator` to cache an expirable UUID
struct CachingUuidGenerator
{
    /// The uuid generator we are decorating
    private let uuidGenerator: UuidGenerator
    
    /// Where we'll be storing uuids
    private let writeRepository: WriteRepository
    
    /// Read repository for retrieving ids
    private let readRepository: ReadRepository
    
    /// Initialise a `CachingUuidGenerator` with the cache and the uuid generator
    ///
    /// - Parameters:
    ///   - readRepository:  The repository to read the uuid from
    ///   - writeRepository: The repository to persist the uuid to
    ///   - uuidGenerator:   The uuid generator we are decorating that actually generates the uuid
    init(
        withReadRepository readRepository: ReadRepository,
        withWriteRepository writeRepository: WriteRepository,
        withUuidGenerator uuidGenerator: UuidGenerator
    )
    {
        self.readRepository  = readRepository
        self.writeRepository = writeRepository
        self.uuidGenerator   = uuidGenerator
    }
    
    /// Get the cached uuid - if it isn't cached, (or is expired, in which case we delete it), create a new one, save it and return that one
    ///
    /// Effectively ensures we always have a fresh uuid according to the timeout in `ExpirableUuid`
    ///
    /// Parameters: forceRegenerate In the case of a 401 unauthorized from `SignedRequest`, UUID might be blocked, so use this to re-generate
    ///
    /// - Returns: A cached or new `ExpirableUuid`
    public func getCachedUuid(forceRegenerate: Bool? = false) -> ExpirableUuid
    {
        if let cachedUuids = self.readRepository.fetchAll(ExpirableUuid.self) as? [ExpirableUuid] {
            for cachedUuid in cachedUuids {                
                if cachedUuid.hasExpired || forceRegenerate == true, let uuidId = cachedUuid.id {
                    _ = self.writeRepository.delete([uuidId])
                    
                    continue
                }
                
                return cachedUuid
            }
        }
        
        return try! await(self.writeRepository.save(ExpirableUuid(uuid: self.uuidGenerator.generate(), created: Date()))) as! ExpirableUuid
    }
}
