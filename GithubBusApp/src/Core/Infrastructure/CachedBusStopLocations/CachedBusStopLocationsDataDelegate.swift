//
//  CachedBusStopLocationsDataDelegate.swift
//  GithubBusApp
//
//  Created by James Mallison on 03/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Foundation

/// Any object implementing this protocol will have the following methods called...
protocol CachedBusStopLocationsDataDelegate
{
    /// The number of elements that will be imported, called as soon as we know the number
    ///
    /// - Parameter count: The count (use this for a progress bar max, for example)
    func countToImport(count: Int) -> Void
    
    /// An element has been imported
    func hasImportedOneMore() -> Void
    
    /// Called once at the end of the import
    func hasFinishedImporting(_ withError: Error?) -> Void
}
