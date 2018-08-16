//
//  ArrayExtensions.swift
//  GithubBusApp
//
//  Created by James Mallison on 08/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Foundation

protocol RandomizableArray
{
    /// Picks n random elements (partial Fisher-Yates shuffle approach)
    ///
    /// - Parameter amount: The amount to pick from the array
    ///
    /// - Returns: The elements from the array
    func getRandomElementWithCount(_ amount: Int) -> [Any]
}

extension Array: RandomizableArray
{
    /// Picks n random elements (partial Fisher-Yates shuffle approach)
    ///
    /// - Parameter amount: The amount to pick from the array
    ///
    /// - Returns: The elements from the array
    public func getRandomElementWithCount(_ amount: Int) -> [Any]
    {
        var copy = self
        
        for i in stride(from: count - 1, to: count - amount - 1, by: -1) {
            copy.swapAt(i, Int(arc4random_uniform(UInt32(i + 1))))
        }
        
        let x: [Any] = Array(copy.suffix(amount))
        
        return x
    }
    
    /// Alias for `getRandomElementWithCount(amount:)` for a single value
    ///
    /// - Returns: The element frmo the array
    public func getRandomElement() -> Any
    {
        return self.getRandomElementWithCount(1).first!
    }
}
