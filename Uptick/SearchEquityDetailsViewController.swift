//
//  SearchEquityDetailsViewController.swift
//  Uptick
//
//  Created by Chris Kong on 12/20/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import UIKit
import SwiftSpinner
import BRYXBanner
import Charts
import CDAlertView
import SafariServices

class SearchEquityDetailsViewController: UIViewController {

    // MARK: Outlets & Properties
    
    @IBOutlet weak var lastTradePriceLabel: UILabel!
    @IBOutlet weak var priceChangesLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var rangeSegmentedControl: XMSegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var feedsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView?
//    @IBOutlet weak var addButton: UIBarButtonItem!

    var selectedSearchEquity: EquitySearch?
    private let datasource = EquityDetailsDataModel()
    fileprivate var equityDetails: EquityDetails? {
        didSet {
            configurePricingView()
            collectionView?.reloadData()
        }
    }
    fileprivate var newsFeed = [EquityNewsFeed]() {
        didSet {
            tableView?.reloadData()
        }
    }
    fileprivate var tweets = [EquityTweet]() {
        didSet {
            tableView?.reloadData()
        }
    }
    fileprivate var chartRangeDelegate: ChartViewRangeDelegate!
    fileprivate var priceChangeViewState = 0
    fileprivate var collectionViewLayout: CustomCollectionViewLayout!
    fileprivate var errorBanner: Banner?
    
    var addButton: UIButton?
    
    var isAdded: Bool = false {
        didSet {
            if isAdded {
                addButton?.setImage(UIImage(named: ImageView.check), for: .normal)
            } else {
                addButton?.setImage(UIImage(named: ImageView.add), for: .normal)
            }
        }
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureChartView()
        lineChartView.delegate = self
        chartRangeDelegate = self
        collectionView?.register(EquityDetailsCollectionViewCell.nib, forCellWithReuseIdentifier: EquityDetailsCollectionViewCell.identifier)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        tableView?.register(EquityFeedDetailsCell.nib, forCellReuseIdentifier: EquityFeedDetailsCell.identifier)
        tableView?.delegate = self
        tableView?.dataSource = self
        datasource.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureData()
        configureRangeSegmentedControl()
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
        
        // CollectionView
        collectionViewLayout = CustomCollectionViewLayout()
        collectionView?.collectionViewLayout = collectionViewLayout
        collectionView?.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        collectionView?.backgroundColor = UIColor.clear
        
        // TableView
        tableView?.backgroundColor = ColorScheme.primaryBackgroundColor
        tableView?.separatorColor = ColorScheme.cellSeparatorColor
        
        // Labels
        self.lastTradePriceLabel.textColor = ColorScheme.primaryPriceInDetailsTextColor
        self.priceChangesLabel.textColor = UIColor.white
        
        // Add Button
        addButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        addButton?.setImage(UIImage(named: ImageView.add), for: .normal)
        addButton?.addTarget(self, action: #selector(addButtonPressed(_:)), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = addButton
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    fileprivate func configureData() {
        title = selectedSearchEquity?.symbol
        self.lastTradePriceLabel.text = selectedSearchEquity?.symbol
        self.datasource.requestData(stockSymbol: (selectedSearchEquity?.symbol)!)
        networkCall(range: .OneDay, symbol: (selectedSearchEquity?.symbol)!)
        fetchNewsFeed(symbol: (selectedSearchEquity?.symbol)!)
        fetchStockTwits(symbol: (selectedSearchEquity?.symbol)!)
        
        // check against userdefaults
        let symbols = UserDefaultsManagement.getTickers()
        if symbols.contains((selectedSearchEquity?.symbol)!) {
            isAdded = true
        } else {
            isAdded = false
        }
    }
    
    fileprivate func configurePricingView() {
        if let lastTradePrice = equityDetails?.lastTradePrice {
            var lastTradeString = Formatters.sharedInstance.stringFromPrice(price: lastTradePrice, currencyCode: "USD")
            let attributedString = NSMutableAttributedString(string: lastTradeString!)
            let letterSpacing: Float = -5.00
            attributedString.addAttribute(NSKernAttributeName, value: (letterSpacing), range: NSMakeRange(0, (lastTradeString?.characters.count)!))
            self.lastTradePriceLabel.attributedText = attributedString
        } else {
            self.lastTradePriceLabel.text = ""
        }
        
        if let changeInPrice = equityDetails?.changeInPrice, let changeInPercent = equityDetails?.changeInPercent {
            var priceChangesString = Formatters.sharedInstance.stringFromPrice(price: changeInPrice, currencyCode: "USD")! + " [" + Formatters.sharedInstance.stringFromPercent(percent: changeInPercent)! + "]"
            let attributedString = NSMutableAttributedString(string: priceChangesString)
            let letterSpacing: Float = -0.50
            attributedString.addAttribute(NSKernAttributeName, value: (letterSpacing), range: NSMakeRange(0, (priceChangesString.characters.count)))
            self.priceChangesLabel.attributedText = attributedString
            
            if changeInPrice > 0.0 {
                self.priceChangesLabel.textColor = ColorScheme.uptickViewColor
                self.priceChangeViewState = 1
            } else if changeInPrice < 0.0 {
                self.priceChangesLabel.textColor = ColorScheme.downtickViewColor
                self.priceChangeViewState = 2
            }
        } else {
            self.priceChangesLabel.text = "$0.00 [0.0%]"
            self.priceChangeViewState = 0
        }
    }
    
    fileprivate func handleLoadEquityDetailsError(_ error: Error) {
        print("Search Equity Details Fetching Error: \(error.localizedDescription)")
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
                print("Search Equity Details Non-Internet Error: \(error.localizedDescription)")
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
        self.errorBanner = Banner(title: "No Internet Connection",
                                  subtitle: "Could not load stock." +
            " Try again when you're connected to the internet",
                                  image: nil,
                                  backgroundColor: .red)
        self.errorBanner?.dismissesOnSwipe = true
        self.errorBanner?.show(duration: nil)
    }
    
    fileprivate func configureRangeSegmentedControl() {
        rangeSegmentedControl.delegate = self
        rangeSegmentedControl.segmentTitle = ["1d", "3m", "1y", "5y"]
        rangeSegmentedControl.backgroundColor = UIColor.clear
        rangeSegmentedControl.highlightColor = UIColor.clear
        rangeSegmentedControl.highlightTint = UIColor.white
        if self.priceChangeViewState == 1 {
            rangeSegmentedControl.tint = ColorScheme.uptickViewColor!
        } else if self.priceChangeViewState == 2 {
            rangeSegmentedControl.tint = ColorScheme.downtickViewColor!
        } else {
            rangeSegmentedControl.tint = ColorScheme.cellPrimaryTextColor!
        }
    }
    
    fileprivate func configureChartView() {
        // to add loading
        lineChartView.noDataText = "Loading data..."
        lineChartView.chartDescription?.text = ""
        lineChartView.drawBordersEnabled = false
        lineChartView.dragEnabled = true
        lineChartView.setScaleEnabled(true)
        lineChartView.pinchZoomEnabled = true
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.leftAxis.drawLabelsEnabled = true
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.labelTextColor = ColorScheme.chartLeftAxisTextColor
        lineChartView.leftAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.enabled = false
        lineChartView.legend.enabled = false
    }
    
    fileprivate func setupChart(range: ChartRange, chartpoints: [EquityChartpoint]) {
        // set data
        var xValues = [String]()
        var yValues = [Double]()
        
        for point in chartpoints {
            switch range {
                case .OneDay:
                    let x = Formatters.sharedInstance.stringFromHours(date: point.date)
                    xValues.append(x!)
                case .ThreeMonth, .OneYear, .FiveYear:
                    let x = Formatters.sharedInstance.stringFromDate(date: point.date)
                    xValues.append(x!)
            }
            let y = point.close
            yValues.append(y!)
        }
        createChart(yValues, xVals: xValues)
    }
    
    fileprivate func createChart(_ values: [Double], xVals: [String]) {
        if(xVals.count == 0) {
            lineChartView.clear()
            lineChartView.clearValues()
            return
        }
        
        var newXVals: [String] = xVals
        
        //add "" becouse of component index bug
        newXVals.append("")
        
        let labelCount = newXVals.count - 1
        self.lineChartView.xAxis.labelCount = labelCount
        self.lineChartView.xAxis.axisMinimum = 0
        self.lineChartView.xAxis.axisMaximum = Double(newXVals.count - 1)
        
        var dataEntries: [ChartDataEntry] = []
        let formatter: ChartFormatter = ChartFormatter()
        formatter.sValues = newXVals
        let xAxis: XAxis = XAxis()
        
        for i in 0..<newXVals.count - 1 {
            let dataEntry = ChartDataEntry(x: Double(i+2), y: values[i])
            dataEntries.append(dataEntry)
            _ = formatter.stringForValue(Double(i), axis: xAxis)
        }
        xAxis.valueFormatter = formatter
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "")
        lineChartDataSet.drawCirclesEnabled = false
        
        var gradientColors = [ColorScheme.lineChartBaseGradientColor?.cgColor,
                              ColorScheme.flatTradeViewColor?.cgColor]
        
        if self.priceChangeViewState == 1 {
            lineChartDataSet.setColor(ColorScheme.uptickViewColor!)
            gradientColors = [ColorScheme.lineChartBaseGradientColor?.cgColor,
                              ColorScheme.uptickViewColor?.cgColor]
        } else if self.priceChangeViewState == 2 {
            lineChartDataSet.setColor(ColorScheme.downtickViewColor!)
            gradientColors = [ColorScheme.lineChartBaseGradientColor?.cgColor,
                              ColorScheme.downtickViewColor?.cgColor]
        } else {
            lineChartDataSet.setColor(ColorScheme.cellPrimaryTextColor!)
            gradientColors = [ColorScheme.lineChartBaseGradientColor?.cgColor,
                              ColorScheme.flatTradeViewColor?.cgColor]
        }
        
        let gradient = CGGradient(colorsSpace: nil,
                                  colors: gradientColors as CFArray,
                                  locations: nil)
        lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient!,
                                                            angle: 90.0)
        lineChartDataSet.drawFilledEnabled = true
        
        let chartData = LineChartData()
        chartData.addDataSet(lineChartDataSet)
        chartData.setDrawValues(false)
        self.lineChartView.data = chartData
        
        self.lineChartView.xAxis.valueFormatter = xAxis.valueFormatter
        self.lineChartView.xAxis.labelPosition = .bottom
        self.lineChartView.animate(xAxisDuration: 2.0,
                                   yAxisDuration: 2.0,
                                   easingOption: .easeInOutQuint)
    }
    
    @IBAction func feedsSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        self.tableView?.reloadData()
    }
    
    func addButtonPressed(_ sender: UIBarButtonItem) {
        print("Button pressed")
    }
    
//    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
//        // add delegate
//        isAdded = !isAdded
//        if isAdded {
//            addButton.setBackgroundImage(UIImage(named: ImageView.check), for: .normal, barMetrics: .default)
//        } else {
//            addButton.setBackgroundImage(UIImage(named: ImageView.add), for: .normal, barMetrics: .default)
//        }
//    }
    
    //  MARK: Network Call Methods
    
    fileprivate func networkCall(range: ChartRange, symbol: String) {
        EquityNetworkManager.requestEquityChartData(symbol: symbol, range: range, onSuccess: { chartpts in
            self.setupChart(range: range, chartpoints: chartpts)
        }, onError: { error in
            print("Chart Error: \(error.localizedDescription)")
            self.handleLoadEquityDetailsError(error)
        })
    }
    
    fileprivate func fetchNewsFeed(symbol: String) {
        EquityNetworkManager.requestEquityNewsFeedData(symbol: symbol, onSuccess: { feeds in
            self.newsFeed = feeds
        }, onError: { error in
            print("Feed Error: \(error.localizedDescription)")
            self.handleLoadEquityDetailsError(error)
        })
    }
    
    fileprivate func fetchStockTwits(symbol: String) {
        EquityNetworkManager.requestEquityTweetData(symbol: symbol, onSuccess: { tweets in
            self.tweets = tweets
        }, onError: { error in
            print("Tweet Error: \(error.localizedDescription)")
            self.handleLoadEquityDetailsError(error)
        })
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.TweetSegue {
            var stockTweetViewController: StockTweetViewController!
            if let tweetNavController = segue.destination as? UINavigationController {
                stockTweetViewController = tweetNavController.topViewController as! StockTweetViewController
                stockTweetViewController.navigationItem.leftItemsSupplementBackButton = true
            } else {
                stockTweetViewController = segue.destination as! StockTweetViewController
            }
            if let selectedRowIndexPath = tableView?.indexPathForSelectedRow {
                let tweet = tweets[selectedRowIndexPath.row]
                stockTweetViewController.selectedTweet = tweet
            }
        }
    }
    
    // MARK: Constants
    
    struct Storyboard {
        static let TweetSegue = "showSearchTweet"
    }
    
    private struct ImageView {
        static let check = "navCheck"
        static let add = "navAdd"
    }

}

extension SearchEquityDetailsViewController: UICollectionViewDelegate { }

extension SearchEquityDetailsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EquityDetailsCollectionViewCell.identifier, for: indexPath) as? EquityDetailsCollectionViewCell {
            if let equity = equityDetails {
                cell.configureItem(indexPath: indexPath.row, item: equity)
            }
            return cell
        }
        return UICollectionViewCell()
    }
}

extension SearchEquityDetailsViewController: UITableViewDelegate { }

extension SearchEquityDetailsViewController: UITableViewDataSource {
    
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
                cell.detailsLabel.text = "by \(tweets[indexPath.row].userName!), \(tweets[indexPath.row].sinceCreated!)"
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

extension SearchEquityDetailsViewController: EquityDetailsViewControllerModelDelegate {
    func didReceiveDataUpdate(data: EquityDetails) {
        self.equityDetails = data
    }
    
    func didFailDataUpdateWithError(error: Error) {
        // handle error with display alert
        handleLoadEquityDetailsError(error)
    }
}

extension SearchEquityDetailsViewController: XMSegmentedControlDelegate {
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

extension SearchEquityDetailsViewController: ChartViewRangeDelegate {
    func didChangeTimeRange(_ range: ChartRange) {
        networkCall(range: range, symbol: (selectedSearchEquity?.symbol)!)
    }
}

extension SearchEquityDetailsViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        //        lineChartView.highlightValue(highlight)
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        print("chart Value Nothing Selected")
    }
}

extension SearchEquityDetailsViewController {
    
    // MARK: Helper
    
    func presentAlertMessage(title: String, message: String) -> Void {
        let alert = CDAlertView(title: title, message: message, type: .error)
        let action = CDAlertViewAction(title: "OK")
        alert.add(action: action)
        alert.show()
    }
}
