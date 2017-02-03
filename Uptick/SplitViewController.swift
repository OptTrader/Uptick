//
//  SplitViewController.swift
//  Uptick
//
//  Created by Chris Kong on 1/10/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        updateMaximumPrimaryColumnWidthBasedOnSize(size: view.bounds.size)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateMaximumPrimaryColumnWidthBasedOnSize(size: size)
    }
    
    func updateMaximumPrimaryColumnWidthBasedOnSize(size: CGSize) {
        if size.width < UIScreen.main.bounds.width || size.width < size.height {
            maximumPrimaryColumnWidth = 300.0
        } else {
            maximumPrimaryColumnWidth = UISplitViewControllerAutomaticDimension
        }
    }
}
