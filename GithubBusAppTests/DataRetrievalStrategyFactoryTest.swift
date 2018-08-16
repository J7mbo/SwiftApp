//
//  DataRetrievalStrategyFactoryTest.swift
//  GithubBusAppTests
//
//  Created by James Mallison on 07/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import XCTest
import Swinject

@testable import GithubBusApp

// The problem is, we should only be writing tests for inputs and outputs, not fucking with this null stuff!
class DataRetrievalStrategyFactoryTest: XCTestCase
{
    private var factory: DataRetrievalStrategyFactory!
    
    override func setUp()
    {
        var containerConfig = ContainerConfiguration()
        let container = containerConfig.createContainer()
        
        self.factory = DataRetrievalStrategyFactory(container)
        
        super.setUp()
    }
    
    public func testCanRetrieveAnInitialStrategy()
    {
        XCTAssertNotNil(getStrategy())
    }
    
    
    public func testCanRetrieveSecondStrategy()
    {
        XCTAssertNotNil(self.factory.getNextAvailableStrategy(fallbackFrom: getStrategy()))
    }
    
    public func testInitialStrategyIsHmac()
    {
        XCTAssertTrue(getStrategy() is HmacDataRetrievalStrategy)
    }
    
    public func testSecondStrategyIsApiToken()
    {
        XCTAssertTrue(getStrategy(fallbackFrom: getStrategy()) is ApiTokenDataRetrievalStrategy)
    }
    
    public func testThirdStrategyIsNil()
    {
        XCTAssertNil(getStrategy(fallbackFrom: getStrategy(fallbackFrom: getStrategy())))
    }
    
    /// Shortcut to `self.factory.getNextAvailableStrategy()`
    private func getStrategy(fallbackFrom fallback: DataRetrievalStrategy? = nil) -> DataRetrievalStrategy?
    {
        return self.factory.getNextAvailableStrategy(fallbackFrom: fallback)
    }
}
