//
//  UnmanagedEntity.swift
//  GithubBusApp
//
//  Created by James Mallison on 03/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Foundation
import CoreData

/// Every `UnmanagedEntity` retains a reference to it's `NSManagedObjectID` for updating / deletion purposes later on
protocol UnmanagedEntity
{
    /// The value object which contains the `NSManagedObjectID`
    var id: UnmanagedEntityId? { get set }
}
