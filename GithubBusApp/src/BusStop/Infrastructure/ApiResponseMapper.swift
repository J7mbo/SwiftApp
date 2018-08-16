//
//  BusStopResponseMapper.swift
//  TestWeb
//
//  Created by James Mallison on 13/12/2017.
//  Copyright © 2017 J7mbo. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

/// Maps the Api Response dictionary to a `BusStop` Entity
struct ApiResponseMapper
{
    public func mapResponseToBusStop(
        withApiResponse response: [String: Any], withStopNumber stopNumber: Int, withLocation location: CLLocation
    ) throws -> BusStop
    {
        guard response["estimaciones"] != nil || response["nombreParada"] != nil else {
            throw NSError(
                domain: "The key estimaciones or nombreParada does not exist in top level of API response, maybe the API hads changed??",
                code: 0,
                userInfo: [:]
            )
        }
        
        guard let addressName = response["nombreParada"] as? String,
              let busLineData = response["estimaciones"] as? [[String: AnyObject]]
        else {
            throw NSError(domain: "Could not get address (nombreParada) or bus lines and estimates (estimaciones) from JSON Response", code: 0, userInfo: [:])
        }
        
        var busLines: [BusLine] = []
        
        for busLine in busLineData {
            var buses: [Bus] = []
            
            guard busLine["color"] != nil,
                  busLine["line"] != nil,
                  let colourHex = busLine["color"] as? String,
                  let lineNumber = Int(busLine["line"] as! String)
            else {
                throw NSError(domain: "Could not get colour (color) or line number (line) from JSON Response", code: 0, userInfo: [:])
            }
            
            /** Each bus for a given line has the same bus number, so should have the same destination, because they're going the same way... but they've repeated the destination for each bus on the api instead of on the line, weird one... so set here and update later because we want the destination on the BusLine of our object API **/
            var destination = ""
            
            for (_, val) in busLine {
                /** If value is just a string, it's for the line and colour, and we already have these - else it's yet another array (the final one) containing our seconds and destination variables - yes this is a great API... **/
                if (val is String) {
                    continue
                }
                
                guard val["destino"] != nil && val["destino"] is String else {
                    throw NSError(domain: "Could not get destination (destino) from JSON Response", code: 0, userInfo: [:])
                }
                
                destination = String(val["destino"] as! String)
                
                guard let arriveInSeconds = val["seconds"] as? Int else {
                    throw NSError(domain: "Could not get number of remaining seconds (seconds) for a bus from JSON Response", code: 0, userInfo: [:])
                }
                
                buses.append(Bus(arrivesInSeconds: arriveInSeconds, isLive: true))
            }
            
            if buses.count > 0 {
                buses.sort { $0.arrivesInSeconds < $1.arrivesInSeconds }
                
                busLines.append(
                    BusLine(lineNumber: lineNumber, colour: UIColor(hexString: colourHex), destination: destination, nextArrivingBuses: buses)
                )
            }
        }
        
        return BusStop(stopNumber: stopNumber, stopAddress: addressName, busLines: busLines, location: location)
    }
}

