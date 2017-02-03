//
//  EquityDetailsViewController.swift
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import UIKit
import SwiftSpinner
import BRYXBanner
import Charts
import CDAlertView
import SafariServices

protocol ChartViewRangeDelegate {
    func didChangeTimeRange(_ range: ChartRange)
}

class EquityDetailsViewController: UIViewController {

    // MARK: Outlets & Properties
    
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var leftViewMainLabel: BottomAlignedLabel!
    @IBOutlet weak var leftViewButton: UIButton!
    @IBOutlet weak var leftViewSubLabel: UILabel!
    @IBOutlet weak var rightViewMainLabel: UILabel!
    @IBOutlet weak var circularProgressView: KDCircularProgress!
    @IBOutlet weak var rightViewButton: UIButton!
    @IBOutlet weak var rightViewSubLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var rangeSegmentedControl: XMSegmentedControl!
    @IBOutlet weak var feedsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView?
    
    var equitySymbol = "AAPL"
    
    private let datasource = EquityDetailsDataModel()
    var equityDetails: EquityDetails? {
        didSet {
            configureDefaultStateLeftView()
            configureDefaultStateRightView()
            
            // what about the rest?
        }
    }
    var newsFeed = [NewsFeed]() {
        didSet {
            tableView?.reloadData()
        }
    }
    var tweets = [Tweet]() {
        didSet {
            tableView?.reloadData()
        }
    }
    var chartRangeDelegate: ChartViewRangeDelegate!
    var leftViewState = 0
    var rightViewState = 0
    var priceChangeViewState = 0
    var errorBanner: Banner?
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
    
    func configureView() {
        // Spinner
        SwiftSpinner.useContainerView(self.view)
        SwiftSpinner.setTitleFont(Font.spinner)
        
        // TableView
        tableView?.backgroundColor = ColorScheme.primaryBackgroundColor
        tableView?.separatorColor = ColorScheme.cellSeparatorColor
        
        // Labels
        self.leftViewMainLabel.text = ""
        self.leftViewSubLabel.text = ""
        self.rightViewMainLabel.text = ""
        self.leftViewSubLabel.text = ""
        self.companyNameLabel.text = ""

        // Add Button
        addButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        addButton?.setImage(UIImage(named: ImageView.add), for: .normal)
        addButton?.addTarget(self, action: #selector(addButtonPressed(_:)), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = addButton
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        // StackView Buttons
        leftViewButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        rightViewButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // Circular Progress View
        circularProgressView.startAngle = -90
        circularProgressView.progressThickness = 0.4
        circularProgressView.trackThickness = 0.5
        circularProgressView.clockwise = true
        circularProgressView.gradientRotateSpeed = 2
        circularProgressView.roundedCorners = false
        circularProgressView.glowMode = .noGlow
        circularProgressView.angle = 0.0
    }
    
    func configureData() {
        title = equitySymbol
        
        self.datasource.requestData(stockSymbol: equitySymbol)
        fetchNewsFeed(symbol: equitySymbol)
        fetchStockTwits(symbol: equitySymbol)
        
        // check against UserDefaults
        let symbols = UserDefaultsManagement.getTickers()
        if symbols.contains(equitySymbol) {
            isAdded = true
        } else {
            isAdded = false
        }
    }
    
    @IBAction func leftViewButtonPressed(_ sender: UIButton) {
        if leftViewState < 2 {
            leftViewState += 1
        } else {
            leftViewState = 0
        }
        let viewState = leftViewState
        switch viewState {
            case _ where viewState == 1:
                configureFirstStateLeftView()
            case _ where viewState == 2:
                configureSecondStateLeftView()
            default:
                configureDefaultStateLeftView()
        }
    }
    
    @IBAction func rightViewButtonPressed(_ sender: UIButton) {
        if rightViewState < 2 {
            rightViewState += 1
        } else {
            rightViewState = 0
        }
        
        let viewState = rightViewState
        switch viewState {
            case _ where viewState == 1:
                configureFirstStateRightView()
            case _ where viewState == 2:
                configureSecondStateRightView()
            default:
                configureDefaultStateRightView()
        }
    }
 
    // MARK: Left StackView Configuration
    
    func configureDefaultStateLeftView() {
        self.leftViewButton.setTitle("Last Trade", for: .normal)
        if (equityDetails?.lastTradePrice != nil) && (equityDetails?.changeInPrice != nil) && (equityDetails?.changeInPercent != nil) {
            if let lastTrade = equityDetails?.lastTradePrice, let changeInPrice = equityDetails?.changeInPrice, let changeInPercent = equityDetails?.changeInPercent {
                self.leftViewMainLabel.attributedText = String.formatPriceLabel(text: Formatters.sharedInstance.stringFromNumber(number: lastTrade)!, priceSpacing: -5, decimalSpacing: -2)
                let priceChangesString = Formatters.sharedInstance.stringFromChangeNumber(number: changeInPrice)! + " [" + Formatters.sharedInstance.stringFromPercent(percent: changeInPercent)! + "]"
                self.leftViewSubLabel.attributedText = String.formatDefaultLabel(text: priceChangesString, spacing: -0.50)
                
                let viewState = self.priceChangeViewState
                switch viewState {
                    case _ where viewState == 1:
                        return self.leftViewSubLabel.textColor = ColorScheme.uptickViewColor
                    case _ where viewState == 2:
                        return self.leftViewSubLabel.textColor = ColorScheme.downtickViewColor
                    default:
                        return self.leftViewSubLabel.textColor = UIColor.white
                }
            }
        } else {
            self.leftViewMainLabel.text = ""
            self.leftViewSubLabel.text = ""

        }
    }
    
    func configureFirstStateLeftView() {
        self.leftViewButton.setTitle("Open", for: .normal)
        if (equityDetails?.open != nil) && (equityDetails?.bid != nil) && (equityDetails?.ask != nil) {
            if let openPrice = equityDetails?.open, let bidPrice = equityDetails?.bid, let askPrice = equityDetails?.ask {
                self.leftViewMainLabel.attributedText = String.formatPriceLabel(text: Formatters.sharedInstance.stringFromNumber(number: openPrice)!, priceSpacing: -5, decimalSpacing: -2)
                let bidAskString = "Bid " + Formatters.sharedInstance.stringFromNumber(number: bidPrice)! + "  |  Ask " + Formatters.sharedInstance.stringFromNumber(number: askPrice)!
                self.leftViewSubLabel.attributedText = String.formatDefaultLabel(text: bidAskString, spacing: -0.50)
                self.leftViewSubLabel.textColor = UIColor.white
            }
        } else {
            self.leftViewMainLabel.text = ""
            self.leftViewSubLabel.text = ""
            self.leftViewSubLabel.textColor = UIColor.white
        }
    }
    
    // TO TEST!!!!
    
    func configureSecondStateLeftView() {
        self.leftViewButton.setTitle("Market Cap", for: .normal)
        if (equityDetails?.marketCap != nil) && (equityDetails?.priceEarningsRatio != nil) && (equityDetails?.dividendYield != nil) {
            if let marketCap = equityDetails?.marketCap, let peRatio = equityDetails?.priceEarningsRatio, let dividendYield = equityDetails?.dividendYield {
                
                self.leftViewMainLabel.attributedText = String.formatMarketCapLabel(text: marketCap, numberSpacing: -5, textSpacing: -2)
                let peDividendString = "PE " + Formatters.sharedInstance.stringFromNumber(number: peRatio)! + "  |  Div Yield " + Formatters.sharedInstance.stringFromPercent(percent: dividendYield)!
                self.leftViewSubLabel.attributedText = String.formatDefaultLabel(text: peDividendString, spacing: -0.50)
                self.leftViewSubLabel.textColor = UIColor.white
            }
        } else {
            self.leftViewMainLabel.text = ""
            self.leftViewSubLabel.text = ""
            self.leftViewSubLabel.textColor = UIColor.white
        }
    }
    
    // MARK: Right StackView Configuration
    
    func configureDefaultStateRightView() {
        self.rightViewButton.setTitle("Day's Range", for: .normal)
        if (equityDetails?.lastTradePrice != nil) && (equityDetails?.dailyLow != nil) && (equityDetails?.dailyHigh != nil) {
            if let lastTrade = equityDetails?.lastTradePrice, let dayLow = equityDetails?.dailyLow, let dayHigh = equityDetails?.dailyHigh {
                let dayRange = dayHigh - dayLow
                let lastTradeOverDayLow = lastTrade - dayLow
                let dayRangePercent = lastTradeOverDayLow / dayRange
                self.rightViewMainLabel.text = ""
                circularProgressView.animate(fromAngle: 0, toAngle: dayRangePercent * 360, duration: 3) { completed in
                }
                let dayRangeString = "L " + Formatters.sharedInstance.stringFromNumber(number: dayLow)! + "  H " + Formatters.sharedInstance.stringFromNumber(number: dayHigh)!
                self.rightViewSubLabel.attributedText = String.formatDefaultLabel(text: dayRangeString, spacing: -0.50)
            }
        } else {
            self.rightViewMainLabel.text = ""
            self.rightViewSubLabel.text = ""
            circularProgressView.angle = 0.0
        }
    }
    
    func configureFirstStateRightView() {
        self.rightViewButton.setTitle("52 Week Range", for: .normal)
        if (equityDetails?.lastTradePrice != nil) && (equityDetails?.yearLow != nil) && (equityDetails?.yearHigh != nil) {
            if let lastTrade = equityDetails?.lastTradePrice, let yearLow = equityDetails?.yearLow, let yearHigh = equityDetails?.yearHigh {
                let yearRange = yearHigh - yearLow
                let lastTradeOverYearLow = lastTrade - yearLow
                let yearRangePercent = lastTradeOverYearLow / yearRange
                self.rightViewMainLabel.text = ""
                circularProgressView.animate(fromAngle: 0, toAngle: yearRangePercent * 360, duration: 3) { completed in
                }
                let yearRangeString = "L " + Formatters.sharedInstance.stringFromNumber(number: yearLow)! + "  H " + Formatters.sharedInstance.stringFromNumber(number: yearHigh)!
                self.rightViewSubLabel.attributedText = String.formatDefaultLabel(text: yearRangeString, spacing: -0.50)
            }
        } else {
            self.rightViewMainLabel.text = ""
            self.rightViewSubLabel.text = ""
            circularProgressView.angle = 0.0
        }
    }
    
    func configureSecondStateRightView() {
        self.rightViewButton.setTitle("% Avg Volume", for: .normal)
        if (equityDetails?.currentVolume != nil) && (equityDetails?.averageDailyVolume != nil) {
            if let currentVolume = equityDetails?.currentVolume, let averageDailyVolume = equityDetails?.averageDailyVolume {
                let averageVolumePercent = Double(currentVolume) / Double(averageDailyVolume)
                self.rightViewMainLabel.attributedText = String.formatDefaultLabel(text: Formatters.sharedInstance.stringFromFlatPercent(percent: averageVolumePercent)!, spacing: -1.50)
                circularProgressView.animate(fromAngle: 0, toAngle: averageVolumePercent * 360, duration: 3) { completed in
                }
                let currentVolumeString = "Volume  " + Formatters.sharedInstance.stringFromInt(int: currentVolume)!
                self.rightViewSubLabel.attributedText = String.formatDefaultLabel(text: currentVolumeString, spacing: -0.50)
            }
        } else {
            self.rightViewMainLabel.text = ""
            self.rightViewSubLabel.text = ""
            circularProgressView.angle = 0.0
        }
    }
    
    
    
    
    // Network Error
    
    func handleLoadEquityDetailsError(_ error: Error) {
        print("Equity Details Fetching Error: \(error.localizedDescription)")
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
                print("Equity Details Non-Internet Error: \(error.localizedDescription)")
                presentAlertMessage(title: "Server Error", message: "Problem fetching data from the server. Please try again later.")
                return
            default:
                break
        }
    }
    
    func showNotConnectedBanner() {
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
    
    func configureRangeSegmentedControl() {
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
    
    func configureChartView() {
        // to add loading
        lineChartView.noDataText = "Loading data..."
        lineChartView.chartDescription?.text = ""
        lineChartView.drawBordersEnabled = false
        lineChartView.dragEnabled = true
        lineChartView.setScaleEnabled(true)
        lineChartView.pinchZoomEnabled = true
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.leftAxis.enabled = false
        lineChartView.rightAxis.drawLabelsEnabled = true
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.labelTextColor = ColorScheme.yAxisTextColor
        lineChartView.rightAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.enabled = false
        lineChartView.legend.enabled = false
    }
    
    func setupChart(range: ChartRange, chartpoints: [Chartpoint]) {
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
        
        if xValues.count == yValues.count {
            createChart(yValues, xVals: xValues)
        } else {
            lineChartView.noDataText = "No Chart Available."
            presentAlertMessage(title: "Chart Error", message: "Problem fetching data from the server. Please try again later.")
        }
    }
    
    func createChart(_ values: [Double], xVals: [String]) {
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
        self.lineChartView.animate(xAxisDuration: 1.0,
                                   yAxisDuration: 1.0,
                                   easingOption: .easeInOutQuint)
    }
    
    @IBAction func feedsSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        self.tableView?.reloadData()
    }
    
    @objc fileprivate func addButtonPressed(_ sender: UIBarButtonItem) {
        // update UserDefaults' Tickers
        let ticker = equitySymbol
        var symbols = UserDefaultsManagement.getTickers()
        
        isAdded = !isAdded
        if isAdded {
            addButton?.setImage(UIImage(named: ImageView.check), for: .normal)
            symbols.append(ticker)
            UserDefaultsManagement.saveTickers(tickers: symbols)
        } else {
            addButton?.setImage(UIImage(named: ImageView.add), for: .normal)
            if symbols.contains(ticker) {
                UserDefaultsManagement.deleteTicker(ticker: ticker)
            }
        }
    }
    
    //  MARK: Network Call Methods
    
    func networkCall(range: ChartRange, symbol: String) {
        EquityNetworkManager.requestChartData(symbol: symbol, range: range, onSuccess: { chartpts in
            self.setupChart(range: range, chartpoints: chartpts)
        }, onError: { error in
            print("Chart Error: \(error.localizedDescription)")
            self.handleLoadEquityDetailsError(error)
        })
    }
    
    func fetchNewsFeed(symbol: String) {
        EquityNetworkManager.requestNewsFeedData(symbol: symbol, onSuccess: { feeds in
            self.newsFeed = feeds
        }, onError: { error in
            print("Feed Error: \(error.localizedDescription)")
            self.handleLoadEquityDetailsError(error)
            
        })
    }
    
    func fetchStockTwits(symbol: String) {
        EquityNetworkManager.requestTweetData(symbol: symbol, onSuccess: { tweets in
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
        static let TweetSegue = "showTweet"
    }
    
    private struct ImageView {
        static let check = "navCheck"
        static let add = "navAdd"
    }
    
}
