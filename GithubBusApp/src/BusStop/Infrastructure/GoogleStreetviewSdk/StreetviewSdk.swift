//
//  StreetviewSdk.swift
//  GithubBusApp
//
//  Created by James Mallison on 05/08/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import CoreLocation
import PromiseKit
import UIKit

/// Whoo! We're making calls to Google Streetview API - now the cheeky bastards require you to have billing on your account (so if you get
/// 403s all the time that's why - note you only need a signature as another GET parameter if the signature requirement is enabled for your app)
struct StreetViewSdk: StreetviewImageRetriever
{
    /// Pulling in the logger from the global scope (sorry global scope gods!)
    private let logger: Logger = log!
    
    /// See: https://developers.google.com/maps/documentation/streetview/intro for parameters
    fileprivate let imageFieldOfView = 120
    
    /// The asset to fall back to in case we couldn't load an image for some reason
    fileprivate let defaultFallbackImage = "default_stop_image"
    
    /// Our API key - Ha like I'd forget to remove this when uploading to Github (please don't forget...!)
    fileprivate let apiKey = "AIzaSyAWxb5reOUpsNGqPJsFyL9LQYXBNkCWo24"
    
    /// The endpoint for retrieving the streetview image - anything in { and } will be overwritten in `loadStreetViewImage(forLocation, ofSize)`
    private var imageRetrievalUrl = "https://maps.googleapis.com/maps/api/streetview{optional}?size={width}x{height}&location={lat},{lon}&fov={fov}&key={apiKey}"
    
    /// How long we're willing to wait for an image from the API
    private let maximumWaitTime = 30.0;
    
    /// Retrieve an image from the google streetview api - you probably want to call this an an async { } with `AwaitKit`
    ///
    /// - Parameters:
    ///   - location: The location of the streetview image
    ///   - size: The size of the image to retrieve
    public func retrieveStreetViewImage(forLocation location: CLLocation, ofSize size: CGSize) -> Promise<UIImage>
    {
        return Promise { resolve, reject in
            let replacements = [
                "{width}": String(format: "%.0f", size.width),
                "{height}": String(format: "%.0f", size.height),
                "{optional}": "/metadata",
                "{lat}": String(location.coordinate.latitude),
                "{lon}": String(location.coordinate.longitude),
                "{fov}": String(self.imageFieldOfView),
                "{apiKey}": self.apiKey
            ]
            
            var url = self.imageRetrievalUrl
            
            for (target, replacement) in replacements {
                url = url.replacingOccurrences(of: target, with: replacement)
            }
            
            logger.debug("Retrieving google streetview image from url: " + url)
            
            // Ensure we get an 'OK' status from the /metadata endpoint first (this is FREE)
            guard self.checkWithMetaDataFirst(url: URL(string: url)!) == true else {
                return resolve(self.getFallbackImage())
            }
            
            let image = self.retrieveImage(
                apiUrl: URL(string: String(describing: url).replacingOccurrences(of: "/metadata", with: ""))!
            )
            
            return resolve(image)
        }
    }
    
    /// Helper to get the fallback image from assets
    private func getFallbackImage() -> UIImage
    {
        return UIImage(named: self.defaultFallbackImage)!
    }
    
    /// Before we get an image from streetview, we call a free /metadata endpoint to check that the image exists and is okay
    ///
    /// - Returns: Whether or not the metadata considers the image available to be downloaded (an 'OK' status)
    private func checkWithMetaDataFirst(url: URL) -> Bool
    {
        let requiredStatus = "OK"
        
        guard let response = try? Data(contentsOf: url),
              let jsonData = try? JSONSerialization.jsonObject(with: response, options: []) as? [String: Any] else {
            return false
        }
        
        guard let status = jsonData!["status"] as? String, status == requiredStatus else {
            logger.error("Did not get 'OK' status from response of street view API - fall back to default image for now")
            
            return false
        }
        
        return true
    }
    
    /// Performed after `checkWithMetaDataFirst(url)`
    private func retrieveImage(apiUrl: URL) -> UIImage
    {
        guard let imageData = try? Data(contentsOf: apiUrl) else {
            logger.error("Error when downloading image from street view API - falling back to default image for now")
            
            return self.getFallbackImage()
        }
        
        return UIImage(data: imageData)!
    }
}
