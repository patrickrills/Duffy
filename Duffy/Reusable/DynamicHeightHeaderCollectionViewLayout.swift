//
//  DynamicHeightHeaderCollectionViewLayout.swift
//  Duffy
//
//  Created by Patrick Rills on 5/23/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import Foundation
import UIKit

class DynamicHeightHeaderCollectionViewLayout: UICollectionViewFlowLayout {
    
    private var cachedHeaderHeight: CGFloat = 0.0
    
    var safeAreaWidth: CGFloat {
        guard let collectionView = collectionView else { return 0.0 }
        return collectionView.bounds.width - collectionView.safeAreaInsets.left - collectionView.safeAreaInsets.right
    }
    
    init(estimatedHeaderHeight: CGFloat) {
        super.init()
        cachedHeaderHeight = estimatedHeaderHeight
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepare() {
        super.prepare()
        
        sectionInsetReference = .fromSafeArea
        headerReferenceSize = CGSize(width: safeAreaWidth, height: cachedHeaderHeight)
    }
        
    override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        switch preferredAttributes.representedElementKind {
        case UICollectionView.elementKindSectionHeader where Int(preferredAttributes.size.height) != Int(originalAttributes.size.height):
            cachedHeaderHeight = preferredAttributes.size.height
            return true
        default:
            return super.shouldInvalidateLayout(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
        }
    }

    override func invalidationContext(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
        switch preferredAttributes.representedElementKind {
        case UICollectionView.elementKindSectionHeader:
            let context = UICollectionViewFlowLayoutInvalidationContext()
            context.invalidateSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader, at: [IndexPath(row: 0, section: 0)])
            return context
        default:
            return super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
        }
    }
    
}
