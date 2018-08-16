//
//  CollectionViewLayoutExtensions.swift
//  GithubBusApp
//
//  Created by James Mallison on 12/03/2018.
//  Copyright © 2018 J7mbo. All rights reserved.
//

import UIKit

/** Thanks to: https://gist.github.com/mmick66/9812223#gistcomment-2241421 **/
class CollectionViewFlowLayoutCenterItem: UICollectionViewFlowLayout
{
    override init() {
        super.init()
        self.scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.scrollDirection = .horizontal
    }
    
    override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        var result = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        
        guard let collectionView = collectionView else {
            return result
        }
        
        let halfWidth = 0.5 * collectionView.bounds.size.width
        let proposedContentCenterX = result.x + halfWidth
        
        let targetRect = CGRect(origin: result, size: collectionView.bounds.size)
        let layoutAttributes = layoutAttributesForElements(in: targetRect)?
            .filter { $0.representedElementCategory == .cell }
            .sorted { abs($0.center.x - proposedContentCenterX) < abs($1.center.x - proposedContentCenterX) }
        
        guard let closest = layoutAttributes?.first else {
            return result
        }
        
        result = CGPoint(x: closest.center.x - halfWidth, y: proposedContentOffset.y)
        return result
    }
}
