//
//  EquityDashboardTableViewController.swift
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import UIKit
import SwiftSpinner
import BRYXBanner
import Pantry
import CDAlertView

class EquityDashboardTableViewController: UITableViewController {

    // MARK: Outlets & Properties
    
    private let datasource = EquityDataModel()    
    var equities = [Equity]() {
        didSet {
            tableView?.reloadData()
        }
    }
    fileprivate var errorBanner: Banner?
    fileprivate var deleteEquityIndexPath: IndexPath? = nil
    fileprivate var viewState = 0
    fileprivate var detailViewController: EquityDetailsViewController? = nil
    var collapseDetailViewController: Bool  = true
    
    // MARK: View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        splitViewController?.preferredDisplayMode = .allVisible
        splitViewController?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        tableView?.register(MainEquityCell.nib, forCellReuseIdentifier: Storyboard.CellIdentifier)
        self.equities = Pantry.unpack(Storyboard.EquityStorage) ?? []
        datasource.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // add refresh control for pull to refresh
        if (self.refreshControl == nil) {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
            self.refreshControl?.addTarget(self,
                                           action: #selector(handleRefresh(sender:)),
                                           for: .valueChanged)
        }
        super.viewWillAppear(animated)
        datasource.requestData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let existingBanner = self.errorBanner {
            existingBanner.dismiss()
        }
        super.viewWillDisappear(animated)
    }
    
    // MARK: Methods
    
    fileprivate func configureView() {
        // Spinner
        SwiftSpinner.useContainerView(self.view)
        SwiftSpinner.setTitleFont(Font.spinner)
        
        // TableView
        tableView?.backgroundColor = ColorScheme.primaryBackgroundColor
        tableView?.separatorColor = ColorScheme.cellSeparatorColor
    }
    
    func handleRefresh(sender: Any) {
        self.datasource.requestData()
        self.refreshControl?.endRefreshing()
    }
    
    fileprivate func handleLoadEquitiesError(_ error: Error) {
        print("Dashboard Error: \(error.localizedDescription)")
        switch error {
            case APIManagerError.network(let innerError as NSError):
                // check for domain
                if innerError.domain != NSURLErrorDomain {
                    break
                }
                // check the code:
                if innerError.code == NSURLErrorNotConnectedToInternet {
                    showNotConnectedBanner()
                    self.equities = Pantry.unpack(Storyboard.EquityStorage) ?? []
                    print("Load From Storage") // temp
                    return
                }
            case APIManagerError.apiProvidedError(reason: error.localizedDescription),
                 APIManagerError.objectSerialization(reason: error.localizedDescription),
                 APIManagerError.jsonError(reason: error.localizedDescription):
                    print("Dashboard Non-Internet Error: \(error.localizedDescription)")
                    presentAlertMessage(title: "Server Error", message: "Problem fetching data from the server. Please try again later.")
                    self.equities = Pantry.unpack(Storyboard.EquityStorage) ?? []
                return
            default:
                break
        }
    }
    
    fileprivate func showNotConnectedBanner() {
        // check for existing banner
        if let existingBanner = self.errorBanner {
            existingBanner.dismiss()
        }
        
        // show not connected error & tell them to try again when they do have a connection
        self.errorBanner = Banner(title: "No Internet Connection",
                                  subtitle: "Could not load stocks." +
            " Try again when you're connected to the internet",
                                  image: nil,
                                  backgroundColor: .red)
        self.errorBanner?.dismissesOnSwipe = true
        self.errorBanner?.show(duration: nil)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.DetailsSegue {
            var equityViewController: EquityDetailsViewController!
            if let detailsNavController = segue.destination as? UINavigationController {
                equityViewController = detailsNavController.topViewController as! EquityDetailsViewController
                equityViewController.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                equityViewController.navigationItem.leftItemsSupplementBackButton = true
            } else {
                equityViewController = segue.destination as! EquityDetailsViewController
            }
            if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
                let equity = equities[selectedRowIndexPath.row]
                equityViewController.equitySymbol = equity.symbol!
            }
        }
    }
    
    // MARK: Constants
    
    fileprivate struct Storyboard {
        static let CellIdentifier = "MainEquityCell"
        static let DetailsSegue = "showDetails"
        static let EquityStorage = "Equity"
    }
}

extension EquityDashboardTableViewController {
    
    // MARK: UITableView Data Source and Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return equities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier, for: indexPath) as? MainEquityCell {
            
            cell.configureItem(state: viewState, item: self.equities[indexPath.item])
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: Storyboard.DetailsSegue, sender: self)
        self.collapseDetailViewController = false
        
        let selectedCell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.black
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cellToDeSelect: UITableViewCell = tableView.cellForRow(at: indexPath)!
        cellToDeSelect.contentView.backgroundColor = UIColor.clear
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteEquityIndexPath = indexPath
            let stockToDelete = equities[indexPath.row]
            confirmDelete(stock: stockToDelete)
        }
    }
    
    func confirmDelete(stock: Equity) {
        let alert = UIAlertController(title: "Delete Stock", message: "Are you sure you want to permanently delete \(stock.symbol!)?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteStock)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteStock)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = self.view.bounds
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleDeleteStock(alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteEquityIndexPath {
            tableView?.beginUpdates()
            
            // update UserDefaults' Tickers
            let ticker = self.equities[indexPath.row].symbol
            
            let symbols = UserDefaultsManagement.getTickers()
            if symbols.contains(ticker!) {
                UserDefaultsManagement.deleteTicker(ticker: ticker!)
            }
            
            self.equities.remove(at: indexPath.row)
            Pantry.pack(self.equities, key: Storyboard.EquityStorage)
            tableView?.deleteRows(at: [indexPath], with: .fade)
            deleteEquityIndexPath = nil
            tableView?.endUpdates()
        }
    }
    
    func cancelDeleteStock(alertAction: UIAlertAction!) {
        deleteEquityIndexPath = nil
    }
}

extension EquityDashboardTableViewController: EquityViewControllerModelDelegate {
    func didReceiveDataUpdate(data: [Equity]) {
        self.equities = data
        Pantry.pack(self.equities, key: Storyboard.EquityStorage)
    }
    
    func didFailDataUpdateWithError(error: Error) {
        handleLoadEquitiesError(error)
        presentAlertMessage(title: "Server Error", message: "Problem with fetching data from server. Please try again later.")
    }
}

extension EquityDashboardTableViewController: MainEquityCellTapPriceInfoDelegate {
    func tappedPriceInfo(cell: MainEquityCell) {
        if viewState < 2 {
            viewState += 1
            tableView.reloadData()
        } else {
            viewState = 0
            tableView.reloadData()
        }
    }
}

extension EquityDashboardTableViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}

extension EquityDashboardTableViewController {
    
    // MARK: Helper
    
    func presentAlertMessage(title: String, message: String) -> Void {
        let alert = CDAlertView(title: title, message: message, type: .error)
        let action = CDAlertViewAction(title: "OK")
        alert.add(action: action)
        alert.show()
    }
}
