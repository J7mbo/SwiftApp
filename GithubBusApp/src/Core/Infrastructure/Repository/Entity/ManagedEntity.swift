//
//  Entity.swift
//  GithubBusApp
//
//  Created by James Mallison on 26/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import CoreData

/// All `NSManagedObject`s that also implement this can be mapped internally by `WriteRepository`
protocol ManagedEntity
{
    var id: String? { get set }
    
    static func mapFromUnmanagedEntity(_ entity: AnyObject, context: NSManagedObjectContext) -> Self?
    
    func mapToUnmanagedEntity() -> Any?
}
