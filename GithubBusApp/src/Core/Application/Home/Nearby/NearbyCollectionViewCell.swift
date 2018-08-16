//
//  NearbyCollectionViewCell.swift
//  GithubBusApp
//
//  Created by James Mallison on 12/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import UIKit
import CoreLocation.CLLocation

/// Tap delegate, the most descriptive name in the world
protocol Delegate
{
    func tap() -> Void
}

/// Represents the nearby bus stop view cell used within `NearbyCollectionViewController`
class NearbyCollectionViewCell: UICollectionViewCell
{
    /// Delegate for handling the user tapping event being fired
    public var delegate: Delegate?
    
    /// We won't show more than this hardcoded number of rows
    private let maximumBusRows = 3
    
    /// The bus stop number in the very top left of the cell
    @IBOutlet weak var stopNumberLabel: UILabel!
    
    /// The label directly below the stop number label containing the distance in meters
    @IBOutlet weak var distanceLabel: UILabel!
    
    /// The stop address directly below the stop image
    @IBOutlet weak var addressLabel: UILabel!
    
    /// The user can tap 'More' on the right to segue to more info
    @IBOutlet weak var moreLabel: UILabel!
    
    /// The view that contains all the row data
    @IBOutlet weak var stackView: UIStackView!
    
    /// The image view containing the google street view image
    @IBOutlet weak var streetviewImage: UIImageView!

    /// Proxy function for forwarding the tap to the delegate
    @objc public func tap()
    {
        self.delegate?.tap()
    }
    
    /// Add all rows to the contained `UIStackView` with data from a `BusStop`
    ///
    /// - Important: As of right now, only the first bus from each line is used
    ///
    /// - Parameters:
    ///     - busStop: The Bus Stop to take one row for each `BusLine` `Bus` from
    ///     - location: The user's location if we want to show the distance
    public func addRowsForNextArrivingBuses(forStop busStop: BusStop, withUserLocation location: CLLocation?) -> Void
    {
        self.moreLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))

        self.stopNumberLabel.text = String(describing: busStop.stopNumber)
        self.addressLabel.text    = busStop.stopAddress
        self.distanceLabel.text   = (location == nil) ? "?" : "📍\(busStop.location.distanceFromAsString(location: location!))m"
        
        busLineLoop: for busLine in busStop.busLines {
            if self.maximumNumberOfRowsAttained() == true {
                break busLineLoop
            }
            
            busLoop: for bus in busLine.nextArrivingBuses {
                if self.maximumNumberOfRowsAttained() == true {
                    break busLineLoop
                }
                
                self.addBusDataToStackView(busLine, bus)
                
                // Only use the first bus on each line
                break busLoop
            }
        }
        
        self.addFillerRowsToStackView(self.stackView.arrangedSubviews.count)
    }
    
    /// The arranged subviews of the stackview are the only things that are created / deleted, all other properties else will just be overwritten anyway
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        for nextBusViewRow in self.stackView.arrangedSubviews {
            nextBusViewRow.removeFromSuperview()
        }
    }
    
    /// Helper to add data from a bus line and bus as a `NextBusView` in the stack view
    ///
    /// - Parameters:
    ///   - busLine: Used for the colour and line number
    ///   - bus:     Used for the destination and number of seconds until arrival time
    fileprivate func addBusDataToStackView(_ busLine: BusLine, _ bus: Bus) -> Void
    {
        self.stackView.addArrangedSubview(
            NextBusView(
                withLineColour: busLine.colour,
                withLineNumber: busLine.lineNumber,
                withLineDestination: busLine.destination,
                withSecondsRemaining: bus.arrivesInSeconds
            )
        )
    }
    
    /// Whether or not we have added the maximum number of rows to the stack view, according to `self.maximumBusRows`
    ///
    /// - Returns: Whether or not we have added the maximum number of rows to the stack view, according to `self.maximumBusRows`
    fileprivate func maximumNumberOfRowsAttained() -> Bool
    {
        return self.stackView.arrangedSubviews.count >= self.maximumBusRows
    }
    
    /// If we specify 3 rows in the stack view but only add two arranged subviews, fill with an empty one to keep nice alignment
    ///
    /// - Parameter dataCount: The count of the data that we already have
    fileprivate func addFillerRowsToStackView(_ dataCount: Int) -> Void
    {
        if dataCount == 0 {
            let label = UILabel(frame: self.stackView.frame)
            
            label.text = "There are no buses until tomorrow"
            
            self.stackView.addArrangedSubview(label)
            
            // Extra subview so label above is at the top not centered
            return self.stackView.addArrangedSubview(UIView())
        }
        
        for _ in 0...self.maximumBusRows - dataCount {
            self.stackView.addArrangedSubview(UIView())
        }
    }
    
    /// Overlay a loading spinner on the image view until loaded - call this when dequeing a cell
    public func startLoadingSpinnerForImage() -> Void
    {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = CGPoint(x: self.streetviewImage.frame.maxX / 2, y: (self.streetviewImage.frame.maxY / 2) + 20)
        activityIndicator.startAnimating()
        activityIndicator.tag = 1337
        
        self.streetviewImage.addSubview(activityIndicator)
    }
    
    /// Stop and remove the loading spinner on the image view until loaded - call this when dequeing a cell, at the end
    public func stopLoadingSpinnerForImage() -> Void
    {
        self.streetviewImage.viewWithTag(1337)?.removeFromSuperview()
    }
}
