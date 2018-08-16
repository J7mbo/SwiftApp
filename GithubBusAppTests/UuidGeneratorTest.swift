//
//  UuidGeneratorTest.swift
//  GithubBusAppTests
//
//  Created by James Mallison on 19/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import XCTest
@testable import GithubBusApp

class UuidGeneratorTest: XCTestCase
{
    private var generator: UuidGenerator!
    
    override public func setUp()
    {
        super.setUp()
        
        generator = UuidGenerator()
    }
    
    public func testGeneratesCorrectFormat()
    {
        // Example: 87156F75-5358-495E-BBE2-0E3CD982A3E0
        let regex = "^.{3}-[0-9A-Z]{8}-[0-9A-Z]{4}-[0-9A-Z]{4}-[0-9A-Z]{4}-[0-9A-Z]{12}$"
        
        XCTAssertTrue(generator.generate().range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil)
    }
}
