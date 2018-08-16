//
//  CachedBusStopLocations.swift
//  GithubBusApp
//
//  Created by James Mallison on 03/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import Foundation
import PromiseKit
import AwaitKit

/// Data is stored in a json file for importing into core data for faster merging with API results data later on
struct CachedBusStopLocations
{
    /// We could start this off but quit the app straight away, so async operation wouldn't complete
    public static let dataSaveCompletedKey = "data_save_completed"
    
    /// The file name containing the json data
    private let jsonFileName = "bus_stop_locations"
    
    /// Where we will store the cached locations in core data
    private let writeRepository: WriteRepository
    
    /// Where we will delete cached locations from if they weren't fully loaded the first time around
    private let readRepository: ReadRepository
    
    /// Where we will store a value holding whether or not we have completed writing everything to the store async (see `dataSaveCompletedKey`
    private let userDefaults: UserDefaults
    
    /// Any object registering as a delegate will be updated on import progress
    public var delegate: CachedBusStopLocationsDataDelegate?
    
    
    /// Initialise an instance of `CachedBusStopLocations`
    ///
    /// - Parameters:
    ///   - writeRepo:    The write repository
    ///   - readRepo:     The read repository
    ///   - userDefaults: The temporary persistence to say whether or not we completed downloading the data
    init(withWriteRepository writeRepo: WriteRepository, withReadRepository readRepo: ReadRepository, withUserDefaults userDefaults: UserDefaults)
    {
        self.writeRepository     = writeRepo
        self.readRepository      = readRepo
        self.userDefaults        = userDefaults
    }

    /// Read json from the deafult json file into core data
    public func readDefaultDataFromJsonFileIntoCoreData() -> Void
    {
        /** We store whether or not this actually succeeded fully, as it could take a second or two, in user defaults **/
        log?.verbose("Deleting all cached locations in persistence and re-transferring json to core data (for caching)")
        
        self.deleteAllLocations()
        self.saveJsonInCoreData()
        
        return
        
    }
    
    /// Read data from json and save to core data
    private func saveJsonInCoreData() -> Void
    {
        /** Intentially crash if any of this fails - it only would if I'm a retarded dev **/
        let jsonFilePath = Bundle.main.path(forResource: self.jsonFileName, ofType: "json")!
        let jsonString   = try! String(contentsOfFile: jsonFilePath, encoding: String.Encoding.utf8)
        
        let data = try! JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding.utf8)!, options: []) as? [String:AnyObject]
        
        let dataDictionary = (data! as NSDictionary)["XXXXXX"] as! NSDictionary
        var countToImport  = dataDictionary.count
        
        self.delegate?.countToImport(count: countToImport)
        
        for (busStopNumber, values) in dataDictionary as! [String:[String]] {
            /** There are a few values in the json that are null because they're bus stops without info yet, ignore them **/
            if values[0] == "null" || values[1] == "null" {
                countToImport -= 1
                
                self.delegate?.countToImport(count: countToImport)
                
                continue
            }
            
            let num: Int32? = Int32(busStopNumber)
            let lat: Float? = Float(values[0])
            let lon: Float? = Float(values[1])
            let loc: String? = String(values[2])
            
            if num == nil || lat == nil || lon == nil || loc == nil {
                continue
            }
            
            let location = BusStopLocation(busStopId: num!, latitude: lat!, longitude: lon!, name: loc!)
            
            do {
                try await(self.writeRepository.save(location))
                
                self.delegate?.hasImportedOneMore()
            } catch {
                /** And this is one reason why location should be nillable in BusStop objects, we might not have it **/
                log?.error("Couldn't save bus stop locations from json file to core data for some reason...")
                
                self.delegate?.hasFinishedImporting(error)
                
                return
            }
        }
        
        UserDefaults.standard.set(true, forKey: type(of: self).dataSaveCompletedKey)
        
        self.delegate?.hasFinishedImporting(nil)
        
        log?.verbose("All bus stop location json data stored successfully in core data")
    }
    
    /// Whether or not the asynchronous data saving completed successfully
    ///
    /// - Returns:  If false, the user quit before we saved everything, so we should delete and try again (to avoid duplicate data)
    private func dataSaveCompleted() -> Bool
    {
        return self.userDefaults.bool(forKey: type(of: self).dataSaveCompletedKey)
    }
    
    /// Delete all bus stop locations
    private func deleteAllLocations() -> Void {
        if let locations: [BusStopLocation] = self.readRepository.fetchAll(BusStopLocation.self) as? [BusStopLocation] {
            let unmanagedEntityIds = locations.compactMap({ (value: BusStopLocation) -> UnmanagedEntityId? in
                return value.id
            })

            _ = try? await(self.writeRepository.delete(unmanagedEntityIds))
        }
    }
}
