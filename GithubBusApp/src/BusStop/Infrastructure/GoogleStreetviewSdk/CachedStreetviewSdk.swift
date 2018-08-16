//
//  StreetviewSdkImageCacher.swift
//  GithubBusApp
//
//  Created by James Mallison on 06/08/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation.CLLocation
import PromiseKit
import AwaitKit

/// Responsible for caching the images from the streetview sdk
struct CachedStreetviewSdk: StreetviewImageRetriever
{
    /// Import logger from the global scope (I did look for AOP for Swift but it wasn't a very nice implementation / was hacky)
    private let logger = log!
    
    /// Store images in the cache with the location as the key, which is unique
    /// Note these are only cached in-memory, not to the disk. Maybe cache to the disk in the future to save API calls
    private let imageCache = NSCache<NSString, UIImage>()
    
    /// The non-caching decorated instance
    private let streetViewSdk: StreetViewSdk = StreetViewSdk()
    
    /// Retrieve an image from the google streetview api - note interanlly calls await on the internal call, use AwaitKit here
    ///
    /// - Parameters:
    ///   - location: The location of the streetview image
    ///   - size: The size of the image to retrieve
    public func retrieveStreetViewImage(forLocation location: CLLocation, ofSize size: CGSize) -> Promise<UIImage>
    {
        return Promise { resolve, reject in
            logger.debug("Checking cache for streetview image")
            
            let cacheKey = "\(location.coordinate.latitude):\(location.coordinate.longitude)" as NSString
            
            if let cachedImage = self.imageCache.object(forKey: cacheKey) {
                logger.debug("Cache contains streetview image, returning (and saving money!!)...")
                
                return resolve(cachedImage)
            }
            
            logger.debug("Cache does not contain streetview image, delegating to api call object...")

            let image = try! await(self.streetViewSdk.retrieveStreetViewImage(forLocation: location, ofSize: size))
            
            logger.debug("Storing image under key: \(cacheKey)")
            
            imageCache.setObject(image, forKey: cacheKey)
            
            return resolve(image)
        }
    }
}
