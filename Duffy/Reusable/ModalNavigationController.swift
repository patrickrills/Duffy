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
        
        navigationBar.prefersLargeTitles = true
        
        if #unavailable(iOS 26.0) {
            navigationBar.tintColor = Globals.secondaryColor()
        }
        
        if let rootViewController = viewControllers.first {
            rootViewController.navigationItem.largeTitleDisplayMode = .always
            modalPresentationStyle = rootViewController.modalPresentationStyle
        }
    }
    
    @objc func donePressed() {
        dismiss(animated: true, completion: nil)
    }
    
    private var addedDoneButton = false
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard viewController == self.viewControllers[0] && !addedDoneButton else {
            return
        }
        
        let doneButton: UIBarButtonItem = UIBarButtonItem.closeBarButtonItem(with: self, action: #selector(donePressed))

        if viewController.navigationItem.rightBarButtonItem != nil {
            viewController.navigationItem.leftBarButtonItem = doneButton
        } else {
            viewController.navigationItem.rightBarButtonItem = doneButton
        }
        
        addedDoneButton = true
    }
}
