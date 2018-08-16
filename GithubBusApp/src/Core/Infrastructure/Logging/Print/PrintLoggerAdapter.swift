//
//  PrintLoggerAdapter.swift
//  GithubBusApp
//
//  Created by James Mallison on 25/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

/// Forwards calls to `Logger` protocol to simply print to the console
struct PrintLoggerAdapter: Logger
{
    /// Forward verbose calls to the console
    ///
    /// - Parameter data: Data to log
    func verbose(_ data: Any)
    {
        print(#function, data)
    }
    
    /// Forward debug calls to the console
    ///
    /// - Parameter data: Data to log
    func debug(_ data: Any)
    {
        print(#function, data)
    }
    
    /// Forward info calls to the console
    ///
    /// - Parameter data: Data to log
    func info(_ data: Any)
    {
        print(#function, data)
    }
    
    /// Forward warning calls to the console
    ///
    /// - Parameter data: Data to log
    func warning(_ data: Any)
    {
        print(#function, data)
    }
    
    /// Forward error calls to the console
    ///
    /// - Parameter data: Data to log
    func error(_ data: Any)
    {
        print(#function, data)
    }
}
