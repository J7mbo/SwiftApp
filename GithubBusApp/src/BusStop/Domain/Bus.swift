//
//  Bus.swift
//  GithubBusApp
//
//  Created by James Mallison on 17/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Foundation

/// A `Bus` runs on a `BusLine` - no bidirectional association needed at this point
struct Bus
{
    /// The number of seconds until the bus arrives
    private(set) var arrivesInSeconds: Int
    
    /// Whether or not the bus time is a live one (we may pull scheduled times in the future as well)
    private(set) var isLive: Bool
}
