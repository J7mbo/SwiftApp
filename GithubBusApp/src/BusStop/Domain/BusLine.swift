//
//  BusLine.swift
//  TestWeb
//
//  Created by James Mallison on 10/12/2017.
//  Copyright © 2017 J7mbo. All rights reserved.
//

import Foundation
import UIKit

/// A `BusLine` can have multiple `Bus`es running on it
struct BusLine
{
    /// Each line has a number - this is basically the buses number on the front of the bus, but it's actually for the line the bus is on
    public private(set) var lineNumber: Int
    
    /// Each line has a colour associated with the number
    public private(set) var colour: UIColor
    
    /// The destination the bus is going to
    public private(set) var destination: String
    
    /// An array of the next buses due to arrive at this stop
    public private(set) var nextArrivingBuses: [Bus]
}

