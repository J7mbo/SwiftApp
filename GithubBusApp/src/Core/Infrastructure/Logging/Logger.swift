//
//  Logger.swift
//  GithubBusApp
//
//  Created by James Mallison on 25/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

/// Exists so we don't couple ourselves to the initial logging implementation from `SwiftyBeaver`
protocol Logger
{
    /// Something not important to log
    ///
    /// - Parameter data: Whatever you want to log
    func verbose(_ data: Any)
    
    /// Something that needs to be debugged during development
    ///
    /// - Parameter data: Whatever you want to log
    func debug(_ data: Any)
    
    /// Some info about general stuff happening in the application
    ///
    /// - Parameter data: Whatever you want to log
    func info(_ data: Any)
    
    /// Some semi-serious fuckery occured
    ///
    /// - Parameter data: Whatever you want to log
    func warning(_ data: Any)
    
    /// Some serious fuckery occured
    ///
    /// - Parameter data: Whatever you want to log
    func error(_ data: Any)
}
