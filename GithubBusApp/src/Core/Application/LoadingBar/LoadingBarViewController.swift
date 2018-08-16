//
//  ViewController.swift
//  GithubBusApp
//
//  Created by James Mallison on 17/02/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import UIKit
import AwaitKit

/// Shows a view with a progress bar for the progress of importing bus stop locations from our json file
class LoadingBarViewController: UIViewController, CachedBusStopLocationsDataDelegate
{
    /// The progress bar in the view
    @IBOutlet weak var progressBar: UIProgressView!
    
    /// The object used to load locations into core data
    public var cachedLocationsLoader: CachedBusStopLocations?
    
    /// The view controller to segue to after finishing loading locations, in a closure so we only resolve when called
    public var initialTabBarController: (() -> (UITabBarController))?
    
    /// Will contain a count of the total number of rows to be imported
    private var progressMax: Int = 0

    /// Will contain the number of rows that have been imported
    private var progressCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.progressBar.setProgress(Float(self.progressCount) / Float(self.progressMax), animated: true)
            }
        }
    }
    
    /// Starts the reading of data from json file
    override func viewDidLoad() {
        super.viewDidLoad()

        self.cachedLocationsLoader?.delegate = self

        _ = async {
            self.cachedLocationsLoader?.readDefaultDataFromJsonFileIntoCoreData()
        }
    }
    
    /// Called by `CachedBusStopLocations` when we get the row count to be imported
    ///
    /// This may be called multiple times as some rows may discarded due to nulls
    ///
    /// - Parameter count: The count to be imported
    func countToImport(count: Int) {
        self.progressMax = count
    }
    
    /// Called by `CachedBusStopLocations` every time a row has been imported
    func hasImportedOneMore() {
        self.progressCount += 1
    }

    /// Called by `CachedBusStopLocations` when all rows have been imported
    ///
    /// - Parameter withError: Any error that occured
    @objc func hasFinishedImporting(_ withError: Error?) {
        if withError != nil {
            log?.error(withError!)
        }
        
        if let initialTabBarController = self.initialTabBarController?() {
            initialTabBarController.hero.isEnabled          = true
            initialTabBarController.hero.modalAnimationType = .zoom

            DispatchQueue.main.async {
                self.present(initialTabBarController, animated: true)
            }
        }
    }
}