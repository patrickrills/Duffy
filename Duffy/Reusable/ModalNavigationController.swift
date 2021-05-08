//
//  ModalNavigationController.swift
//  Duffy
//
//  Created by Patrick Rills on 11/10/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit

class ModalNavigationController: UINavigationController, UINavigationControllerDelegate {
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        initialize()
    }
    
    init(rootViewController: UIViewController, doneButtonSystemImageName: String, onDismiss: @escaping () -> ()) {
        super.init(rootViewController: rootViewController)
        self.doneButtonSystemImageName = doneButtonSystemImageName
        self.onDismiss = onDismiss
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }
    
    private func initialize() {
        self.delegate = self
        navigationBar.tintColor = Globals.secondaryColor()
        navigationBar.prefersLargeTitles = true
        if let rootViewController = viewControllers.first {
            rootViewController.navigationItem.largeTitleDisplayMode = .always
            modalPresentationStyle = rootViewController.modalPresentationStyle
        }
    }
    
    //TODO: support iOS 13 modal pull down dismissing
    
    @objc func donePressed() {
        dismiss(animated: true, completion: { [weak self] in
            self?.onDismiss?()
        })
    }
    
    private var addedDoneButton = false
    private var doneButtonSystemImageName: String?
    private var onDismiss: (() -> ())?
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard viewController == self.viewControllers[0] && !addedDoneButton else {
            return
        }
        
        var doneButton: UIBarButtonItem
        if #available(iOS 13.0, *) {
            doneButton = UIBarButtonItem(image: UIImage(systemName: doneButtonSystemImageName ?? "xmark.circle"), style: .plain, target: self, action: #selector(donePressed))
        } else {
            doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        }
        
        if viewController.navigationItem.rightBarButtonItem != nil {
            viewController.navigationItem.leftBarButtonItem = doneButton
        } else {
            viewController.navigationItem.rightBarButtonItem = doneButton
        }
        
        addedDoneButton = true
    }
}
