//
//  LocationAuthorizationChangeHandler.swift
//  GithubBusApp
//
//  Created by James Mallison on 27/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import UIKit
import SwiftLocation

/// Responsible for responding to a change in location authorization - the user may deny location or have it turned off in settings
class LocationAuthorizationChangeHandler
{
    /// The alert will be triggered for the instance of `UIViewController` set as the delegate here
    public weak var viewControllerDelegate: UIViewController?
    
    /// The actual alert to be displayed
    lazy private var alertController: UIAlertController = {
        let ac = UIAlertController(
            title: "GithubBusApp Location Services",
            message: "GithubBusApp needs your location for most of the app - please Open Settings and enable it",
            preferredStyle: .alert
        )
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        ac.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        })
        
        return ac
    }()
    
    /// Listen for the user not yet having accepted or having denied location access and either request / show an alert respectively
    ///
    /// - Important: If no `viewControllerDelegate` is set then no alert will be shown
    public func listenForEvents() -> Void
    {
        Locator.events.listen { newStatus in
            switch (newStatus) {
                case .notDetermined:
                    return Locator.requestAuthorizationIfNeeded(.whenInUse)
                case .denied:
                    return self.viewControllerDelegate?.present(self.alertController, animated: true, completion: nil) ?? Void()
                default:
                    break
            }
        }
    }
}

