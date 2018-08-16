//
//  NextBusView.swift
//  GithubBusApp
//
//  Created by James Mallison on 17/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import UIKit
import Hero

/// Each `NextBusView` is a row the `UIStackView` in `NearbyCollectionViewCell`
class NextBusView: UIView
{
    // MARK: - Required properties
    
    /// The colour of the bus line, used as the background colour for view containing the `lineNumber`
    private var lineColour: UIColor?
    
    /// The line number to display on the left of the row
    private var lineNumber: Int?
    
    /// The destination to display in the middle of the row
    private var lineDestination: String?

    /// The seconds remaining to display on the right of the row
    private var secondsRemaining: Int?
    
    // MARK: - Subview Setup
    
    /// This is the line number view to be displayed on the left
    lazy private var lineNumberView: UILabel = {
        let label = UILabel()
        
        [label].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.adjustsFontSizeToFitWidth = true
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
            $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            $0.textColor = .white
            $0.textAlignment = .center
            $0.text = String(describing: lineNumber!)
            $0.backgroundColor = lineColour!
        }
        
        return label
    }()
    
    /// This is the description containing "SES ILLETES in 15 minutes"
    lazy private var descriptionView: UILabel = {
        let label = UILabel()
        
        let formattedString = NSMutableAttributedString()
        
        formattedString.normal("\(lineDestination!) in ", 15)

        // @todo internal struct to hold this?
        var suffix = "seconds"
        var remaining = self.secondsRemaining!
        
        if (secondsRemaining! > 60) {
            suffix = "minutes"
            remaining /= 60
        }
        
        // Okay now we're into hours, this is enough...
        if (remaining > 60) {
            suffix = "hours"
            remaining /= 60
        }
        
        formattedString.bold("\(remaining) \(suffix)", 15)
        
        label.attributedText = formattedString
        
        [label].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.adjustsFontSizeToFitWidth = true
        }
        
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    init(withLineColour colour: UIColor, withLineNumber num: Int, withLineDestination dest: String, withSecondsRemaining seconds: Int)
    {
        super.init(frame: .zero)
        
        self.hero.modifiers = [.whenMatched(.useNoSnapshot), .spring(stiffness: 300, damping: 25)]
        
        self.lineColour       = colour
        self.lineNumber       = num
        self.lineDestination  = dest
        self.secondsRemaining = seconds
        self.setup()
    }
    
    // MARK: - Setup
    
    /// Set up the views
    private func setup() -> Void
    {
        if self.lineColour == nil || self.lineNumber == nil || self.lineDestination == nil || self.secondsRemaining == nil {
            return
        }
        
        setupLineNumberView()
        setupDescriptionView()
    }
    
    /// Set up the constraints for `self.lineNumberView`
    private func setupLineNumberView() -> Void
    {
        self.addSubview(self.lineNumberView)

        NSLayoutConstraint.activate([
            self.lineNumberView.topAnchor.constraint(equalTo: self.topAnchor),
            self.lineNumberView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.lineNumberView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.lineNumberView.heightAnchor.constraint(equalTo: self.heightAnchor),
            self.lineNumberView.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    /// Set up the constraints for `self.descriptionView`
    private func setupDescriptionView() -> Void
    {
        self.addSubview(self.descriptionView)
        
        NSLayoutConstraint.activate([
            self.descriptionView.topAnchor.constraint(equalTo: self.topAnchor),
            self.descriptionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.descriptionView.leadingAnchor.constraint(equalTo: self.lineNumberView.trailingAnchor, constant: 10),
            self.descriptionView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
    }
}
