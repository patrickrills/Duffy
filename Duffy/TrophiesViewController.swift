//
//  TrophiesViewController.swift
//  Duffy
//
//  Created by Patrick Rills on 3/6/21.
//  Copyright © 2021 Big Blue Fly. All rights reserved.
//

import UIKit
import DuffyFramework

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
        
        collectionView.register(UINib(nibName: String(describing: TrophyCollectionViewCell.self), bundle: Bundle.main), forCellWithReuseIdentifier: String(describing: TrophyCollectionViewCell.self))
        collectionView.register(TrophiesFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: String(describing: TrophiesFooterView.self))
        collectionView.register(TrophiesHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: TrophiesHeaderView.self))
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trophies.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TrophyCollectionViewCell.self), for: indexPath) as? TrophyCollectionViewCell else { fatalError("Cell is not TrophyCollectionViewCell") }
        
        let trophy = trophies[indexPath.item]
        cell.bind(to: trophy, isBig: indexPath.row == 0)

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: TrophiesHeaderView.self), for: indexPath)
        case UICollectionView.elementKindSectionFooter:
            guard let buttonFooter = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: TrophiesFooterView.self), for: indexPath) as? TrophiesFooterView else {
                fallthrough
            }
            
            buttonFooter.bind(NSLocalizedString("How To Change Your Goal", comment: ""), onPress: { [weak self] in
                self?.navigationController?.pushViewController(GoalInstructionsTableViewController(), animated: true)
            })
            
            return buttonFooter
        default:
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
    
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

fileprivate class TrophyLayout: UICollectionViewFlowLayout {
    
    enum Constants {
        static let SPACING: CGFloat = 20.0
        static let CELL_HEIGHT: CGFloat = 82.0
        static let FOOTER_HEIGHT: CGFloat = 100.0
        static let FOOTER_BUTTON_HEIGHT: CGFloat = 48.0
        static let HEADER_ESTIMATED_HEIGHT: CGFloat = 64.0
    }
    
    var firstItemSize: CGSize = .zero
    
    private var cachedHeaderHeight: CGFloat = Constants.HEADER_ESTIMATED_HEIGHT
    
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
        
        footerReferenceSize = CGSize(width: availableWidth, height: Constants.FOOTER_HEIGHT)
        headerReferenceSize = CGSize(width: availableWidth, height: cachedHeaderHeight)
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

fileprivate class TrophiesFooterView: UICollectionReusableView {
    
    private lazy var buttonFooterView: ButtonFooterView = {
        let footer = ButtonFooterView()
        footer.translatesAutoresizingMaskIntoConstraints = false
        footer.buttonAttributedText = NSAttributedString(string: "")
        footer.addTarget(self, action: #selector(pressed))
        footer.separatorIsVisible = false
        footer.backgroundColor = .clear
        return footer
    }()
    
    private var pressHandler: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createView()
    }
    
    private func createView() {
        backgroundColor = .clear
        addSubview(buttonFooterView)
        NSLayoutConstraint.activate([
            buttonFooterView.topAnchor.constraint(equalTo: topAnchor),
            buttonFooterView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonFooterView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonFooterView.heightAnchor.constraint(equalToConstant: TrophyLayout.Constants.FOOTER_BUTTON_HEIGHT)
        ])
    }
    
    @objc private func pressed() {
        pressHandler?()
    }
    
    func bind(_ buttonText: String, onPress: @escaping () -> ()) {
        buttonFooterView.buttonAttributedText = NSAttributedString(string: buttonText)
        pressHandler = onPress
    }
}

fileprivate class TrophiesHeaderView: UICollectionReusableView {
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = GoalInstructions.step4.text(useLegacyInstructions: false)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createView()
    }
    
    private func createView() {
        backgroundColor = .clear
        addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: TrophyLayout.Constants.SPACING),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: TrophyLayout.Constants.SPACING),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -TrophyLayout.Constants.SPACING)
        ])
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let preferredLayoutAttributes = layoutAttributes

        var fittingSize = UIView.layoutFittingCompressedSize
        fittingSize.width = preferredLayoutAttributes.size.width
        let size = systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
        var adjustedFrame = preferredLayoutAttributes.frame
        adjustedFrame.size.height = ceil(size.height)
        preferredLayoutAttributes.frame = adjustedFrame
        
        return preferredLayoutAttributes
    }
}
