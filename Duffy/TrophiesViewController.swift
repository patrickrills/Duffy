//
//  TrophiesViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 3/6/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

private let reuseIdentifier = "Cell"

class TrophiesViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    init() {
        super.init(collectionViewLayout: TrophyLayout())
    }
    
    required init?(coder: NSCoder) {
        super.init(collectionViewLayout: TrophyLayout())
    }
    
    private lazy var trophies: [Trophy] = {
        return Trophy.allCases
                .filter {
                    $0 != .none
                }
                .sorted {
                    $0.factor() > $1.factor()
                }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Trophies", comment: "")
        
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = .systemGroupedBackground
        } else {
            collectionView.backgroundColor = Globals.lightGrayColor()
        }
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trophies.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let trophy = trophies[indexPath.item]
    
        if #available(iOS 13.0, *) {
            cell.backgroundColor = .secondarySystemGroupedBackground
        } else {
            cell.backgroundColor = .white
        }
        
        if #available(iOS 14.0, *) {
            var contentConfig = UIListContentConfiguration.subtitleCell()
            contentConfig.text = "\(trophy.symbol()): \(trophy.stepsRequired()) steps"
            contentConfig.secondaryText = Globals.distanceFormatter().string(for: trophy.factor())
            cell.contentConfiguration = contentConfig
        }
    
        return cell
    }
    
    //TODO: Header and Footer
//    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let trophyLayout = collectionViewLayout as? TrophyLayout else { fatalError("Layout is not TrophyLayout") }
        switch indexPath.row {
        case 0:
            return trophyLayout.firstItemSize
        default:
            return trophyLayout.itemSize
        }
    }
}

class TrophyLayout: UICollectionViewFlowLayout {
    
    private enum Constants {
        static let SPACING: CGFloat = 20.0
        static let CELL_HEIGHT: CGFloat = 84.0
    }
    
    var firstItemSize: CGSize = .zero
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        let margin = Constants.SPACING
        sectionInset = UIEdgeInsets(top: margin, left:margin, bottom: margin, right: margin)
        minimumLineSpacing = margin
        minimumInteritemSpacing = margin
        
        let availableWidth = collectionView.bounds.inset(by: sectionInset).size.width
        let cellWidth = ((availableWidth - margin) / 2.0).rounded(.down)
        itemSize = CGSize(width: cellWidth, height: Constants.CELL_HEIGHT)
        firstItemSize = CGSize(width: availableWidth, height: Constants.CELL_HEIGHT * 2.0)
    }
}
