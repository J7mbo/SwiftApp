//
//  SwiftyBeaverLoggerAdapter.swift
//  GithubBusApp
//
//  Created by James Mallison on 25/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import SwiftyBeaver

/// Forwards calls to `Logger` protocol to `SwiftyBeaver` framework
struct SwiftyBeaverLoggerAdapter: Logger
{
    /// The logging library we're adapting calls to
    private let logger: SwiftyBeaver.Type
    
    /// Initialiser for `SwiftyBeaverLoggerAdapter`
    ///
    /// - Parameter beaverLoggingLib: Create this with `SwiftyBeaver.self`
    init(_ beaverLoggingLib: SwiftyBeaver.Type)
    {
        logger = beaverLoggingLib
    }
    
    /// Forward verbose calls to the logging library
    ///
    /// - Parameter data: Data to log
    public func verbose(_ data: Any)
    {
        self.logger.self.verbose(data)
    }
    
    /// Forward debug calls to the logging library
    ///
    /// - Parameter data: Data to log
    public func debug(_ data: Any)
    {
        self.logger.self.debug(data)
    }
    
    /// Forward info calls to the logging library
    ///
    /// - Parameter data: Data to log
    public func info(_ data: Any)
    {
        self.logger.self.info(data)
    }
    
    /// Forward warning calls to the logging library
    ///
    /// - Parameter data: Data to log
    public func warning(_ data: Any)
    {
        self.logger.self.warning(data)
    }
    
    /// Forward error calls to the logging library
    ///
    /// - Parameter data: Data to log
    public func error(_ data: Any)
    {
        self.logger.self.error(data)
    }
}
