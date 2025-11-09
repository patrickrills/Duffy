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
        
        collectionView.backgroundColor = .systemGroupedBackground
        
        collectionView.register(TipCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: TipCollectionViewCell.self))
        collectionView.register(ButtonFooterCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: String(describing: ButtonFooterCollectionReusableView.self))
        collectionView.register(LabelHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: LabelHeaderCollectionReusableView.self))
        
        retrieveOptions()
    }
    
    private func retrieveOptions() {
        collectionView.allowsSelection = false
        
        Task {
            do {
                let tips = try await TipService.getInstance().tipOptions()
                self.tipOptions = tips.sorted { $0.price < $1.price }
                await MainActor.run {
                    self.collectionView.allowsSelection = true
                    self.collectionView.reloadData()
                }
            } catch {
                LoggingService.log(error: error)
                await MainActor.run {
                    self.displayMessage(NSLocalizedString("Unable to communicate with the App Store. Do you want to try again?", comment: ""), retry: {
                        self.retrieveOptions()
                    })
                }
            }
        }
    }
    
    private func tip(_ optionId: TipIdentifier) {
        Task {
            do {
                _ = try await TipService.getInstance().tip(productId: optionId)
                await MainActor.run {
                    self.displayMessage(NSLocalizedString("Thanks so much for the tip! 🙏", comment: ""), retry: nil)
                }
            } catch {
                LoggingService.log(error: error)
                await MainActor.run {
                    self.displayMessage(NSLocalizedString("Your tip did not go through. Do you want to try again?", comment: ""), retry: {
                        self.tip(optionId)
                    })
                }
            }
        }
    }
    
    private func displayMessage(_ message: String, retry: (() -> ())?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        if let retry = retry {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Try Again", comment: ""), style: .default, handler: { _ in
                retry()
            }))
            
            let reloadCollection: (UIAlertAction) -> () = { [weak collectionView] _ in
                collectionView?.reloadData()
            }
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: reloadCollection))
        } else {
            let navigateBack: (UIAlertAction) -> () = { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .cancel, handler: navigateBack))
        }
        
        present(alert, animated: true, completion: nil)
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
        guard let option = tipOptions.first(where: { $0.identifier == TipIdentifier.allCases[indexPath.row] }) else { return }
        tip(option.identifier)
        
        collectionView.deselectItem(at: indexPath, animated: true)
        if let tipCell = collectionView.cellForItem(at: indexPath) as? TipCollectionViewCell {
            tipCell.bind(to: nil)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let labelHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: LabelHeaderCollectionReusableView.self), for: indexPath) as? LabelHeaderCollectionReusableView else {
                fallthrough
            }
            
            labelHeader.headerLabel.text = NSLocalizedString("My name is Patrick and I aspire to make apps people love. When I created Duffy, I never expected to be paid. That’s why there are no ads, subscriptions, or data collection of any kind. I just want to hone my craft while also serving a need.\n\nDuffy is a labor of love that happens after hours and on the weekends so it helps to know that people appreciate the work I do maintaining and improving this app.\n\nIf Duffy is an app that you love, and you can afford it, please consider showing your appreciation by selecting one of the tips below:", comment: "")
            return labelHeader
        case UICollectionView.elementKindSectionFooter:
            guard let buttonFooter = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: ButtonFooterCollectionReusableView.self), for: indexPath) as? ButtonFooterCollectionReusableView else {
                fallthrough
            }
            
            buttonFooter.bind(NSLocalizedString("Learn more about Duffy", comment: ""), onPress: { [weak self] in
                self?.navigationController?.openURL("http://www.bigbluefly.com/duffy")
            })
            
            return buttonFooter
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
}

fileprivate class TipsLayout: DynamicHeightHeaderCollectionViewLayout {
    
    enum Constants {
        static let SPACING: CGFloat = 20.0
        static let CELL_HEIGHT: CGFloat = 82.0
        static let FOOTER_HEIGHT: CGFloat = 100.0
        static let HEADER_ESTIMATED_HEIGHT: CGFloat = 100.0
    }
    
    init() {
        super.init(estimatedHeaderHeight: Constants.HEADER_ESTIMATED_HEIGHT)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
        
        footerReferenceSize = CGSize(width: availableWidth, height: Constants.FOOTER_HEIGHT)
    }
    
}
