//
//  SplitViewSupport.swift
//  Uptick
//
//  Created by Chris Kong on 1/10/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import UIKit

//  MARK: iPad Support

extension UISplitViewController: UISplitViewControllerDelegate {
    
    struct iosSupport {
        static var modeButtonItem: UIBarButtonItem?
    }
    
    var backBarButtonItem: UIBarButtonItem? {
        get {
            if responds(to: #selector(getter: UISplitViewController.displayModeButtonItem)) == true {
                let button: UIBarButtonItem = displayModeButtonItem
                return button
            } else {
                return iosSupport.modeButtonItem
            }
        }
        set {
            iosSupport.modeButtonItem = newValue
        }
    }
    
    func displayModeButtonItem(_: Bool = true) -> UIBarButtonItem? {
        return backBarButtonItem
    }
    
    public func splitViewController(_ svc: UISplitViewController, willShow aViewController: UIViewController, invalidating barButtonItem: UIBarButtonItem) {
        if (!svc.responds(to: #selector(getter: UISplitViewController.displayModeButtonItem))) {
            if let detailView = svc.viewControllers[svc.viewControllers.count - 1] as? UINavigationController {
                svc.backBarButtonItem = nil
                detailView.topViewController?.navigationItem.leftBarButtonItem = nil
            }
        }
    }
    
    // MARK: User defined implementation of UISplitViewControllerDelegate
    
    public func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let navController = primaryViewController as? UINavigationController {
            if let controller = navController.topViewController as? EquityDashboardTableViewController {
                return controller.collapseDetailViewController
            }
        }
        return true
    }
}
