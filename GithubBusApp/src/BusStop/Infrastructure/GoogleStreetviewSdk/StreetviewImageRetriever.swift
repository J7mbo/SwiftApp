//
//  StreetviewImageRetriever.swift
//  GithubBusApp
//
//  Created by James Mallison on 06/08/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import CoreLocation.CLLocation
import PromiseKit

/// We need to be able to retrieve images from Google Streetview
protocol StreetviewImageRetriever
{
    /// Retrieve an image from the google streetview api - you probably want to call this an an async { } with `AwaitKit`
    ///
    /// - Parameters:
    ///   - location: The location of the streetview image
    ///   - size: The size of the image to retrieve
    func retrieveStreetViewImage(forLocation location: CLLocation, ofSize size: CGSize) -> Promise<UIImage>
}
