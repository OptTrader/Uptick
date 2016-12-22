//
//  SearchEquityViewController.swift
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import UIKit
import SwiftSpinner
import BRYXBanner
import CDAlertView

class SearchEquityViewController: UIViewController {
    
    // MARK: Outlets & Properties
    
    @IBOutlet weak var tableView: UITableView?
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var shouldShowSearchResults = false
    private let datasource = SearchEquityDataModel()
    fileprivate var searchResults = [EquitySearch]() {
        didSet {
            tableView?.reloadData()
        }
    }
    fileprivate var errorBanner: Banner?
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        tableView?.register(SearchEquityCell.nib, forCellReuseIdentifier: SearchEquityCell.identifier)
        tableView?.delegate = self
        tableView?.dataSource = self
        datasource.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        title = "Search"
        configureSearchController()
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
    
    fileprivate func configureSearchController() {
        // Initialize and perform a minimum configuration to the search controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = ColorScheme.navigationBarForegroundColor
        searchController.searchBar.barTintColor = ColorScheme.primaryBackgroundColor
        definesPresentationContext = true
        
        // Place the search bar view to the tableview headerview.
        tableView?.tableHeaderView = searchController.searchBar
    }

    fileprivate func filterContentForSearchText(searchText: String) {
        datasource.requestData(searchText: searchText)
    }
    
    fileprivate func handleSearchError(_ error: Error) {
        print("Search Error: \(error.localizedDescription)")
        switch error {
            case APIManagerError.network(let innerError as NSError):
                // check for domain
                if innerError.domain != NSURLErrorDomain {
                    break
                }
                // check the code:
                if innerError.code == NSURLErrorNotConnectedToInternet {
                    showNotConnectedBanner()
                    return
                }
            case APIManagerError.apiProvidedError(reason: error.localizedDescription),
                 APIManagerError.objectSerialization(reason: error.localizedDescription),
                 APIManagerError.jsonError(reason: error.localizedDescription):
                print("Search Non-Internet Error: \(error.localizedDescription)")
                presentAlertMessage(title: "Server Error", message: "Problem fetching data from the server. Please try again later.")
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
                                  subtitle: "Could not search stock." +
            " Try again when you're connected to the internet",
                                  image: nil,
                                  backgroundColor: .red)
        self.errorBanner?.dismissesOnSwipe = true
        self.errorBanner?.show(duration: nil)
    }

    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.SearchDetailsSegue  {
            if let selectedRowIndexPath = tableView?.indexPathForSelectedRow {
                let equity = searchResults[selectedRowIndexPath.row]
                let controller = segue.destination as! SearchEquityDetailsViewController
                controller.selectedSearchEquity = equity
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
            
        }
        
//        if segue.identifier == Storyboard.SearchDetailsSegue {
//            var searchEquityDetailsViewController: SearchEquityDetailsViewController!
//            if let detailsNavController = segue.destination as? UINavigationController {
//                searchEquityDetailsViewController = detailsNavController.topViewController as! SearchEquityDetailsViewController
//                searchEquityDetailsViewController.navigationItem.leftItemsSupplementBackButton = true
//            } else {
//                searchEquityDetailsViewController = segue.destination as! SearchEquityDetailsViewController
//            }
//            if let selectedRowIndexPath = tableView?.indexPathForSelectedRow {
//                let equity = searchResults[selectedRowIndexPath.row]
//                searchEquityDetailsViewController.selectedSearchEquity = equity
//            }
//        }
    }
    
    // MARK: Constants
    
    fileprivate struct Storyboard {
//        static let SearchEquityDetailsViewController = "SearchEquityDetailsViewController"
        static let SearchDetailsSegue = "showSearchDetails"
    }
}

// MARK: UITableView Data Source and Delegate

extension SearchEquityViewController: UITableViewDelegate { }

extension SearchEquityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SearchEquityCell.identifier, for: indexPath) as? SearchEquityCell {
            
            cell.configureItem(item: searchResults[indexPath.item])
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: Storyboard.SearchDetailsSegue, sender: self)
    }
}

extension SearchEquityViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            self.tableView?.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.navigationItem.setHidesBackButton(true, animated: true)
        shouldShowSearchResults = true
        self.tableView?.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.setHidesBackButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchResults.removeAll()
        shouldShowSearchResults = false
        self.tableView?.reloadData()
    }
}

extension SearchEquityViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text ?? ""
        guard !searchString.isEmpty else {
            self.searchResults = []
            return
        }
        self.filterContentForSearchText(searchText: searchString)
    }
}

extension SearchEquityViewController: SearchEquityCellDelegate {
    func didAddButtonPressed(cell: SearchEquityCell) {
        if let indexPath = tableView?.indexPath(for: cell) {
            searchResults[indexPath.row].isAdded = searchResults[indexPath.row].isAdded ? false : true
            
            // update UserDefaults' Tickers
            let ticker = searchResults[indexPath.row].symbol
            
            var symbols = UserDefaultsManagement.getTickers()
            if symbols.contains(ticker!) {
                UserDefaultsManagement.deleteTicker(ticker: ticker!)
            } else {
                symbols.append(ticker!)
                UserDefaultsManagement.saveTickers(tickers: symbols)
            }
        }
    }
}

extension SearchEquityViewController: SearchEquityViewControllerModelDelegate {
    func didReceiveSearchData(data: [EquitySearch]) {
        self.searchResults = data
    }
    
    func didFailSearchDataWithError(error: Error) {
        handleSearchError(error)
    }
}

extension SearchEquityViewController {
    
    // MARK: Helper
    
    func presentAlertMessage(title: String, message: String) -> Void {
        let alert = CDAlertView(title: title, message: message, type: .error)
        let action = CDAlertViewAction(title: "OK")
        alert.add(action: action)
        alert.show()
    }
}
