//
//  ContainerConfiguration.swift
//  GithubBusApp
//
//  Created by James Mallison on 04/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Swinject
import SwinjectAutoregistration
import SwinjectStoryboard
import CoreData.NSPersistentContainer
import SwiftLocation

struct ContainerConfiguration
{
    private var container: Container?
    
    // MARK: - Container initialisation
    
    mutating public func createContainer() -> Container
    {
        self.container = Container()
        Container.loggingFunction = nil
        
        self.setUpGeneric()
        self.setUpLoadingBarViewController()
        self.setUpHomeViewController()
        self.setUpDataRetrievalStrategies()
        self.setUpNearbyViewController()
        self.setupNearbyCollectionViewController()
        
        return self.container!
    }
    
    // MARK: - Generic shared services
    
    mutating private func setUpGeneric()
    {
        // @todo I literally have no idea how to access this from the main thread without crashing here
        container!.register(NSPersistentContainer.self) { r in return (UIApplication.shared.delegate as! AppDelegate).persistentContainer }

        container!.register(UserDefaults.self) { r in return UserDefaults.standard }
        
        container!.register(URLSession.self) { r in return URLSession.shared}
        
        container!.autoregister(CachedBusStopLocationsDetector.self, initializer: CachedBusStopLocationsDetector.init(withUserDefaults:))
        
        container!.autoregister(BusStopLocationRepository.self, initializer: BusStopLocationRepository.init(_:))
        
        container!.autoregister(LocationAuthorizationChangeHandler.self, initializer: LocationAuthorizationChangeHandler.init)
        
        container!.register(UserLocator.self) { r in SwiftLocationUserLocator(withLocatorManager: Locator) }
    }
    
    // MARK: - LoadingBarViewController
    
    mutating private func setUpLoadingBarViewController()
    {
        container!.autoregister(WriteRepository.self, initializer: WriteRepository.init)
        container!.autoregister(ReadRepository.self, initializer: ReadRepository.init)
        container!.autoregister(CachedBusStopLocations.self, initializer: CachedBusStopLocations.init)

        container!.register(LoadingBarViewController.self) { r in
            let c = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoadingBarViewController") as! LoadingBarViewController
            
            c.cachedLocationsLoader   = r.resolve(CachedBusStopLocations.self)
            c.initialTabBarController = { r.resolve(UITabBarController.self)! }

            return c
        }
    }
    
    // MARK: - HomeViewController
    
    mutating private func setUpHomeViewController()
    {
        let c = self.container!
        
        // TODO: make this named, or else subclass to a UITabBarController so we can have multiple registered within the application
        container!.register(UITabBarController.self) { r in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let tbVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            let nVC  = storyboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
            let hVC  = SwinjectStoryboard
                .create(name: "Main", bundle: nil, container: c)
                .instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            
            hVC.locationAuthorizationHandler = r.resolve(LocationAuthorizationChangeHandler.self)

            nVC.viewControllers  = [hVC]
            tbVC.viewControllers = [nVC]
            
            return tbVC
        }
    }
    
    // MARK: - Data Retrieval Strategies
    
    mutating private func setUpDataRetrievalStrategies()
    {
        // MARK: HmacDataRetrievalStrategy

        container!.autoregister(UrlRequestFactory.self, initializer: UrlRequestFactory.init)
        container!.autoregister(UuidGenerator.self, initializer: UuidGenerator.init)
        container!.register(ApiCredentials.Environment.self) { _ in return ApiCredentials.Environment.production }
        container!.autoregister(ApiCredentials.self, initializer: ApiCredentials.init(forEnvironment:withUuidGenerator:))
        container!.autoregister(NetworkRequestClient.self, initializer: UrlSessionNetworkRequestClient.init(withURLSession:withUrlRequestFactory:))
        container!.autoregister(UrlSessionNetworkRequestClient.self, initializer: UrlSessionNetworkRequestClient.init(withURLSession:withUrlRequestFactory:))
        container!.autoregister(CachingUuidGenerator.self, initializer: CachingUuidGenerator.init(withReadRepository:withWriteRepository:withUuidGenerator:))
        container!.autoregister(HmacDataRetrievalStrategy.self, initializer: HmacDataRetrievalStrategy.init(client:apiCredentials:))
        
        // MARK: ApiTokenDataRetrievalStrategy
        
        container!.autoregister(ApiTokenDataRetrievalStrategy.self, initializer: ApiTokenDataRetrievalStrategy.init(withNetworkRequestClient:))
        
        let c = container!

        container!.register(DataRetrievalStrategyFactory.self) { r in
            return DataRetrievalStrategyFactory(c)
        }
    }
    
    // MARK: - NearbyViewController
    
    mutating private func setUpNearbyViewController()
    {
        container!.autoregister(ApiResponseMapper.self, initializer: ApiResponseMapper.init)
        container!.autoregister(BusStopLocationRepository.self, initializer: BusStopLocationRepository.init(_:))
        
        container!.autoregister(
            BusTimesService.self, initializer: BusTimesService.init(withReadRepository:withDataRetrievalStrategyFactory:withResponseMapper:)
        )
        
        container!.storyboardInitCompleted(NearbyViewController.self) { r, c in
            c.userLocator               = r.resolve(UserLocator.self)
            c.busStopLocationRepository = r.resolve(BusStopLocationRepository.self)
            c.busTimesService           = r.resolve(BusTimesService.self)
        }
    }
    
    // Mark: NearbyCollectionViewController
    
    mutating private func setupNearbyCollectionViewController()
    {
        container!.autoregister(CachedStreetviewSdk.self, initializer: CachedStreetviewSdk.init)
        
        container!.storyboardInitCompleted(NearbyCollectionViewController.self) { r, c in
            c.streetviewImageRetriever = r.resolve(CachedStreetviewSdk.self)
        }
    }
}
