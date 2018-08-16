//
//  SwiftyBeaverLoggerAdapterFactory.swift
//  GithubBusApp
//
//  Created by James Mallison on 25/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import SwiftyBeaver

/// Responsible for creating a `SwiftyBeaverLoggerAdapter` instance, with configuration depending on environment
struct SwiftyBeaverLoggerAdapterFactory
{
    /// Configures logging destination for `SwiftyBeaver` depending on debug or production environment
    ///
    /// - Returns: The logging adapter ready to use in `AppDelegate`
    static func create() -> SwiftyBeaverLoggerAdapter
    {
        let logger = SwiftyBeaver.self
        
        /** For now, let's just log to the console **/
        #if DEBUG
            logger.addDestination(ConsoleDestination())
        #else
            logger.addDestination(ConsoleDestination())
        #endif
        
        return SwiftyBeaverLoggerAdapter(logger)
    }
}
