//
//  HomeViewController.swift
//  GithubBusApp
//
//  Created by James Mallison on 04/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import UIKit
import Swinject
import Hero

class HomeViewController: UIViewController
{
    /// The date label at the top in the storyboard
    @IBOutlet weak var dateLabel: UILabel!
    
    /// The vertical scroll view containing all the container sub-views
    @IBOutlet weak var scrollView: UIScrollView!
    
    /// The handler to ensure that we can respond to the user declining to provide location
    public var locationAuthorizationHandler: LocationAuthorizationChangeHandler?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupDateLabel()
        
        self.locationAuthorizationHandler?.listenForEvents()
    }
    
    /// Sets the date label in the storyboard to be today's date (uses `DateFormatter().formatWithDaySuffix(from:andWithFormat:)` extension
    private func setupDateLabel()
    {
        dateLabel.text = DateFormatter().formatWithDaySuffix(from: Date(), andWithFormat: "dd MMM YYYY").uppercased()
    }
}
