//
//  DataRetrievalStrategyFactory.swift
//  GithubBusApp
//
//  Created by James Mallison on 06/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Swinject

/// Responsible for retrieving a `DataRetrievalStrategy` at runtime and falling back to the next one if it fails
struct DataRetrievalStrategyFactory
{
    /// A factory can use whatever it needs to perform its job, even a DiC
    private let container: Container
    
    /// Initialise an instance of `DataRetrievalStrategyFactory`
    ///
    /// - Parameter container: The DiC for runtime strategy resolution
    init(_ container: Container)
    {
        self.container = container
    }
    
    /// Developer-provided, add your strategies here as callables in order of highest priority, highest at the top
    private func getAvailableStrategies() -> Array<[String: () -> (DataRetrievalStrategy)]>
    {
        return [
            [String(describing: HmacDataRetrievalStrategy.self): { self.container.resolve(HmacDataRetrievalStrategy.self)! }],
            [String(describing: ApiTokenDataRetrievalStrategy.self): { self.container.resolve(ApiTokenDataRetrievalStrategy.self)! }]
        ]
    }
    
    /// Get the next available strategy to retrieve data (optionally after a previous one), registered within `getAvailableStrategies()`
    ///
    /// - Parameter currentStrategy: Optionally pass a previous strategy here to get the next one
    ///
    /// - Returns: The next available strategy, or nil if there is not one
    public func getNextAvailableStrategy(fallbackFrom currentStrategy: DataRetrievalStrategy? = nil) -> DataRetrievalStrategy?
    {
        if currentStrategy == nil {
            return self.getAvailableStrategies().first?.first?.value()
        }
        
        let concreteStrategyClassName = String(describing: currentStrategy.self).components(separatedBy: ".")[1].components(separatedBy: "(")[0]
        
        guard let element = self.getAvailableStrategies().enumerated().first(where: { $0.element.keys.first == concreteStrategyClassName }) else {
            return nil
        }
        
        let elementIndex = self.getAvailableStrategies().index(element.offset, offsetBy: 0)
        
        if !self.getAvailableStrategies().indices.contains(elementIndex + 1) {
            return nil
        }
        
        return self.getAvailableStrategies()[elementIndex + 1].first!.value()
    }
    
}
