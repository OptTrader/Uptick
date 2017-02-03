//
//  MenuPagesViewController.swift
//  Uptick
//
//  Created by Chris Kong on 1/20/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import UIKit

class MenuPagesViewController: UIViewController {

    // MARK: Properties
    
    var pageMenu: CAPSPageMenu?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.title = Menu.TitleIdentifier
        
        // Scroll Menu 
        var controllerArray: [UIViewController] = []
        
        let indicesTableViewController: IndicesTableViewController = IndicesTableViewController()
        indicesTableViewController.title = Menu.IndicesIdentifier
        controllerArray.append(indicesTableViewController)
        
        let equityDashboardTableViewController: EquityDashboardTableViewController = EquityDashboardTableViewController()
        equityDashboardTableViewController.title = Menu.StocksIdentifier
        controllerArray.append(equityDashboardTableViewController)
        
        let currenciesCollectionViewController: CurrenciesCollectionViewController = CurrenciesCollectionViewController()
        currenciesCollectionViewController.title = Menu.CurrenciesIdentifier
        controllerArray.append(currenciesCollectionViewController)
        
        // Customize Menu / CHECK
        let parameters: [CAPSPageMenuOption] = [.scrollMenuBackgroundColor(ColorScheme.primaryBackgroundColor!),
                                                .selectionIndicatorColor(ColorScheme.menuSelectionColor!),
                                                .bottomMenuHairlineColor(UIColor(white: 1, alpha: 0.2)),
                                                .menuItemFont(Font.menu),
                                                .menuHeight(40.0),
                                                .menuItemWidth(90.0),
                                                .centerMenuItems(true),
                                                .addBottomMenuShadow(true),
                                                .menuShadowColor(UIColor.white),
                                                .menuShadowRadius(4)]
        
        // Initialize Scroll Menu
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.frame.width, height: self.view.frame.height))
        pageMenu = CAPSPageMenu(viewControllers: controllerArray,
                                frame: rect,
                                pageMenuOptions: parameters)
        
        self.addChildViewController(pageMenu!)
        self.view.addSubview(pageMenu!.view)
        
        pageMenu!.didMove(toParentViewController: self)
    }
    
    // MARK: Container View Controller
    
    override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return true
    }
    
    fileprivate struct Menu {
        static let TitleIdentifier = "Uptick"
        static let IndicesIdentifier = "Indices"
        static let StocksIdentifier = "Stocks"
        static let CurrenciesIdentifier = "Currencies"
    }
}
