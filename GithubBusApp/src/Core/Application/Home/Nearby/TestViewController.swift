//
//  TestViewController.swift
//  GithubBusApp
//
//  Created by James Mallison on 17/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import UIKit
import Hero

/// When the user taps 'More' this is shown
class DetailViewController: UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupHeroAnimation()
        
        self.view.backgroundColor = .red
    }
    
    /// Utilises the hero library to manage view controller transitions
    fileprivate func setupHeroAnimation() -> Void
    {
        self.hero.isEnabled = true
        self.hero.modalAnimationType = .cover(direction: .up)
    }
}
