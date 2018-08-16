//
//  NearbyCollectionViewController.swift
//  GithubBusApp
//
//  Created by James Mallison on 12/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import CoreLocation.CLLocation
import AwaitKit
import UIKit
import Hero

/// The view controller contained within `NearbyViewController` displaying the user-swipeable nearby bus stop 'cards' - it uses the `busStops` internal property and `addBusStops(busStops:)` to present these entities as an instance of `NextBusView` within each `NearbyCollectionViewCell`
class NearbyCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, Delegate
{
    /// SDK used to retrieve bus stop images from the Google Streetview API
    public var streetviewImageRetriever: StreetviewImageRetriever?
    
    /// Set repeatedly in `addBusStops`
    private var usersLocation: CLLocation?
    
    /// Page control is created programatically as it cannot be added in the storyboard easily
    lazy private var pageControl: UIPageControl = {
        let pg = UIPageControl()
        
        [pg].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.pageIndicatorTintColor                    = .lightGray
            $0.currentPageIndicatorTintColor             = UIColor.init(hexString: "#197DFB")
        }
        
        self.view.addSubview(pg)
        
        return pg
    }()
    
    /// The identifier to dequeue reusable collection view cells with
    private let cellReuseId = "NearbyCollectionViewCell"
    
    /// Default to five of the closest bus stops (this is also user-configurable) - also used to decide how many actual queries to make so public
    public var numberOfCellsToShow: Int = 5
    
    /// BusStops are added here with a call to `addBusStops(busStops:)`
    private var busStops: [BusStop] = []
    
    /// MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupCollectionView()
        self.setupPageControl()
    }
    
    /// Add the data from a `BusStop` to the collection and have it displayed as a new collection view cell - typically this is `NearbyViewController` that will retrieve the bus stops and call this method with them to add new bus stops
    ///
    /// - Parameters:
    ///     - busStops: The bus stops to be displayed in the cells
    ///     - location: The current user's location, required if we want to show the distance to the bus stop in each cell
    public func addBusStops(_ busStops: [BusStop], withCurrentLocation location: CLLocation?) -> Void
    {
        self.usersLocation = location
        
        func cellCountLimitReached() -> Bool {
            return self.busStops.count >= self.numberOfCellsToShow
        }
        
        // Throw a million bus stops here and we don't care, the maximum limit has been defined
        if cellCountLimitReached() {
            return
        }

        for busStop in busStops {
            if cellCountLimitReached() {
                break
            }
            
            self.busStops.append(busStop)
        }
        
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    /// Remove all bus stops from the collection view
    ///
    /// - Parameter reload: If true, call `UICollectionView.reloadData()` which will remove the cells due to 0 `BusStop`s
    public func removeAllBusStops(andReloadData reload: Bool = false)
    {
        self.busStops.removeAll()
        
        if reload == true {
            self.collectionView?.reloadData()
        }
    }
    
    /// Defaults for this collection view
    private func setupCollectionView()
    {
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView?.showsHorizontalScrollIndicator = false
    }
    
    /// Add the page control constraints: note the `pageControl` property is lazy loaded
    private func setupPageControl()
    {
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
            pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }
    
    /// If the user starts scrolling, update the page control before scrolling has finished
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        self.pageControl.currentPage = indexPath.row
    }
    
    /// If the user starts scrolling, but then returns to the previous one, update the page control at the end of scrolling instead
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    /// The number of cells to show in the single horizontal section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let numberOfCells = self.numberOfCellsToShow
        
        self.pageControl.numberOfPages = numberOfCellsToShow
        
        return numberOfCells
    }
    
    /// Dequeuing the reusable cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellReuseId, for: indexPath) as! NearbyCollectionViewCell
        
        if self.busStops.indices.contains(indexPath.item) {
            let busStop = self.busStops[indexPath.item]

            cell.addRowsForNextArrivingBuses(forStop: busStop, withUserLocation: self.usersLocation)
            cell.delegate = self
            
            // Every time we dequeue a re-usable cell, we potentially have to update the image too!
            DispatchQueue.main.async {
                cell.startLoadingSpinnerForImage()
            }

            async {
                let image: UIImage? = try! await(self.streetviewImageRetriever!.retrieveStreetViewImage(
                    forLocation: busStop.location, ofSize: CGSize(width: 600, height: 300)
                ))
                
                DispatchQueue.main.async {
                    cell.streetviewImage.image = image

                    cell.stopLoadingSpinnerForImage()
                }
            }
        }

        return cell
    }
    
    /// The size of the cell should be the same size as the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.safeAreaLayoutGuide.layoutFrame.width, height: collectionView.safeAreaLayoutGuide.layoutFrame.height)
    }
    
    // The spacing between the cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 20
    }
    
    @objc func tap() {
        present(DetailViewController(), animated: true, completion: nil)
    }
}
