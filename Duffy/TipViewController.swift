//
//  TipViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 5/15/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

class TipViewController: UICollectionViewController {

    private var tipOptions = [TipOption]()
    
    init() {
        super.init(collectionViewLayout: TipsLayout())
    }
    
    required init?(coder: NSCoder) {
        super.init(collectionViewLayout: TipsLayout())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Tip Jar", comment: "")
        
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = .systemGroupedBackground
        } else {
            collectionView.backgroundColor = Globals.lightGrayColor()
        }

        self.collectionView.register(TipCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: TipCollectionViewCell.self))
        
        retrieveOptions()
    }
    
    private func retrieveOptions() {
        collectionView.allowsSelection = false
        
        TipService.getInstance().tipOptions { [weak self] result in
            switch result {
            case.success(let tips):
                self?.tipOptions = tips
                DispatchQueue.main.async {
                    self?.collectionView.allowsSelection = true
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                //TODO: Show error and retry
                LoggingService.log(error: error)
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TipIdentifier.allCases.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TipCollectionViewCell.self), for: indexPath) as? TipCollectionViewCell else { fatalError("Cell is not TipCollectionViewCell") }
        cell.bind(to: tipOptions.first(where: { $0.identifier == TipIdentifier.allCases[indexPath.row] }))
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tip = tipOptions.first(where: { $0.identifier == TipIdentifier.allCases[indexPath.row] }) else { return }
        collectionView.deselectItem(at: indexPath, animated: true)
        TipService.getInstance().tip(productId: tip.identifier) { result in
            switch result {
            case .success(_):
                //TODO: show thanks
                print("Thanks for the tip!!")
            case .failure(let error):
                //TODO: Show error and retry
                LoggingService.log(error: error)
            }
        }
    }
}

fileprivate class TipsLayout: UICollectionViewFlowLayout {
    
    enum Constants {
        static let SPACING: CGFloat = 20.0
        static let CELL_HEIGHT: CGFloat = 82.0
    }
    
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
    }
    
}
