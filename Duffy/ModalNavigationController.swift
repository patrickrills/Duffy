//
//  ModalNavigationController.swift
//  Duffy
//
//  Created by Patrick Rills on 11/10/18.
//  Copyright © 2018 Big Blue Fly. All rights reserved.
//

import UIKit

class ModalNavigationController: UINavigationController
{
    override init(rootViewController: UIViewController)
    {
        super.init(rootViewController: rootViewController)
        navigationBar.tintColor = Globals.secondaryColor()
        rootViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        
        if #available(iOS 11.0, *)
        {
            navigationBar.prefersLargeTitles = true
            rootViewController.navigationItem.largeTitleDisplayMode = .always
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @IBAction func donePressed()
    {
        dismiss(animated: true, completion: nil)
    }
}
