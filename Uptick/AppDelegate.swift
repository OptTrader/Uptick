//
//  AppDelegate.swift
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if let splitViewController = self.window!.rootViewController as? UISplitViewController {
            let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
            navigationController.topViewController?.navigationItem.leftItemsSupplementBackButton = true
            splitViewController.delegate = splitViewController
        }
        
        applyStyles()
        return true
    }
    
    private func applyStyles() {
        let navigationBar = UINavigationBar.appearance()
        navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: ColorScheme.navigationBarForegroundColor ?? UIColor.white,
            NSFontAttributeName: Font.navigationBar]
        navigationBar.tintColor = ColorScheme.navigationBarForegroundColor
        navigationBar.barTintColor = ColorScheme.navigationBarBackgroundColor
    }

}
