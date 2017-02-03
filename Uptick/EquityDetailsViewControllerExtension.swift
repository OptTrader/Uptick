//
//  EquityDetailsViewControllerExtension.swift
//  Uptick
//
//  Created by Chris Kong on 2/3/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import UIKit
import SwiftSpinner
import BRYXBanner
import Charts
import CDAlertView
import SafariServices

extension EquityDetailsViewController: UITableViewDelegate { }

extension EquityDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if feedsSegmentedControl.selectedSegmentIndex == 0 {
            return newsFeed.count
        }
        else if feedsSegmentedControl.selectedSegmentIndex == 1 {
            return tweets.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: EquityFeedDetailsCell.identifier, for: indexPath) as? EquityFeedDetailsCell {
            
            if feedsSegmentedControl.selectedSegmentIndex == 0 {
                cell.headingLabel.text = newsFeed[indexPath.row].currentTitle
                cell.detailsLabel.text = newsFeed[indexPath.row].sincePublishDate
            }
            else if feedsSegmentedControl.selectedSegmentIndex == 1 {
                cell.headingLabel.text = tweets[indexPath.row].tweet
                cell.detailsLabel.text = "by \(tweets[indexPath.row].userName!). \(tweets[indexPath.row].sinceCreated!)"
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch feedsSegmentedControl.selectedSegmentIndex {
        case 0:
            let feed = self.newsFeed[indexPath.row]
            let urlString = feed.currentLink
            let url = URL(string: urlString)
            
            let safariViewController = SFSafariViewController(url: url!)
            safariViewController.title = feed.currentTitle
            self.navigationController?.pushViewController(safariViewController, animated: true)
        case 1:
            self.performSegue(withIdentifier: Storyboard.TweetSegue, sender: self)
        default:
            break
        }
    }
}

extension EquityDetailsViewController: EquityDetailsViewControllerModelDelegate {
    func didReceiveDataUpdate(data: EquityDetails) {
        if let changeInPrice = data.changeInPrice {
            if changeInPrice > 0.0 {
                self.priceChangeViewState = 1
            } else if changeInPrice < 0.0 {
                self.priceChangeViewState = 2
            } else {
                self.priceChangeViewState = 0
            }
        }
        
        self.equityDetails = data
        self.companyNameLabel.text = data.companyName!
        self.configureDefaultStateRightView()
        self.configureDefaultStateLeftView()
        networkCall(range: .OneDay, symbol: equitySymbol)
    }
    
    func didFailDataUpdateWithError(error: Error) {
        // handle error with display alert
        handleLoadEquityDetailsError(error)
    }
}

extension EquityDetailsViewController: XMSegmentedControlDelegate {
    func xmSegmentedControl(_ xmSegmentedControl: XMSegmentedControl, selectedSegment: Int) {
        var range: ChartRange = .OneDay
        
        switch selectedSegment {
            case 0: range = .OneDay
            case 1: range = .ThreeMonth
            case 2: range = .OneYear
            case 3: range = .FiveYear
                
            default: range = .OneDay
        }
        chartRangeDelegate.didChangeTimeRange(range)
    }
}

extension EquityDetailsViewController: ChartViewRangeDelegate {
    func didChangeTimeRange(_ range: ChartRange) {
        networkCall(range: range, symbol: equitySymbol)
    }
}

extension EquityDetailsViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        //        lineChartView.highlightValue(highlight)
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        print("Chart Value Nothing Selected")
    }
}

extension EquityDetailsViewController {
    
    // MARK: Helper
    
    func presentAlertMessage(title: String, message: String) -> Void {
        let alert = CDAlertView(title: title, message: message, type: .error)
        let action = CDAlertViewAction(title: "OK")
        alert.add(action: action)
        alert.show()
    }
}
