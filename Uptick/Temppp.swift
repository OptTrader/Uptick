
//override func viewDidLoad() {
//    super.viewDidLoad()
//    self.title = equitySymbol
//    circularProgressView.startAngle = -90
//    circularProgressView.progressThickness = 0.4
//    circularProgressView.trackThickness = 0.5
//    circularProgressView.clockwise = true
//    circularProgressView.gradientRotateSpeed = 2
//    circularProgressView.roundedCorners = false
//    circularProgressView.glowMode = .noGlow
//    

//    //
//    leftViewButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    rightViewButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    self.leftViewMainLabel.text = ""
//    self.leftViewSubLabel.text = ""
//    self.rightViewMainLabel.text = ""
//    self.leftViewSubLabel.text = ""
//    self.companyNameLabel.text = ""
//    circularProgressView.angle = 0.0
//    



//    YahooFinanceApiClient.requestEquityDetailsData(symbol: equitySymbol, onSuccess: { equity in
//        if let changeInPrice = equity.changeInPrice {
//            if changeInPrice > 0.0 {
//                self.priceChangeViewState = 1
//            } else if changeInPrice < 0.0 {
//                self.priceChangeViewState = 2
//            } else {
//                self.priceChangeViewState = 0
//            }
//        }
//        self.equityDetails = equity
//        self.companyNameLabel.text = self.equityDetails?.companyName!
//        //            self.configureInfoForLeftView(state: 0)
//        //            self.configureInfoForRightView(state: 0)
//        self.configureDefaultStateLeftView()
//        self.configureDefaultStateRightView()
//        
//    }, onError: { error in
//        print(error.localizedDescription)
//    })
//    
//}
//
//@IBAction func leftViewButtonPressed(_ sender: UIButton) {
//    if leftViewState < 2 {
//        leftViewState += 1
//        //            configureInfoForLeftView(state: leftViewState)
//    } else {
//        leftViewState = 0
//        //            configureInfoForLeftView(state: leftViewState)
//    }
//    
//    let viewState = leftViewState
//    switch viewState {
//    case _ where viewState == 1:
//        configureFirstStateLeftView()
//    case _ where viewState == 2:
//        configureSecondStateLeftView()
//    default:
//        configureDefaultStateLeftView()
//    }
//    
//}
//
//@IBAction func rightViewButtonPressed(_ sender: UIButton) {
//    if rightViewState < 2 {
//        rightViewState += 1
//        //            configureInfoForRightView(state: rightViewState)
//    } else {
//        rightViewState = 0
//        //            configureInfoForRightView(state: rightViewState)
//    }
//    
//    let viewState = rightViewState
//    switch viewState {
//    case _ where viewState == 1:
//        configureFirstStateRightView()
//    case _ where viewState == 2:
//        configureSecondStateRightView()
//    default:
//        configureDefaultStateRightView()
//    }
//}

//
//    func configureDefaultStateLeftView() {
//        self.leftViewButton.setTitle("Last Trade", for: .normal)
//        self.leftViewMainLabel.attributedText = String.formatPriceLabel(
//            text: Formatters.sharedInstance.stringFromNumber(number: self.equityDetails!.lastTradePrice!)!,
//            priceSpacing: -5,
//            decimalSpacing: -2)
//        if let changeInPrice = equityDetails?.changeInPrice, let changeInPercent = equityDetails?.changeInPercent {
//            let priceChangesString = Formatters.sharedInstance.stringFromChangeNumber(number: changeInPrice)! + "  [" + Formatters.sharedInstance.stringFromPercent(percent: changeInPercent)! + "]"
//            self.leftViewSubLabel.attributedText = String.formatDefaultLabel(text: priceChangesString, spacing: -0.50)
//            
//            let viewState = self.priceChangeViewState
//            switch viewState {
//            case _ where viewState == 1:
//                return self.leftViewSubLabel.textColor = ColorScheme.uptickViewColor
//            case _ where viewState == 2:
//                return self.leftViewSubLabel.textColor = ColorScheme.downtickViewColor
//            default:
//                return self.leftViewSubLabel.textColor = ColorScheme.flatTradeViewColor
//            }
//        } else {
//            self.leftViewSubLabel.text = "0.00  [0.0%]"
//        }
//        
//    }
//    
//    func configureFirstStateLeftView() {
//        self.leftViewButton.setTitle("Open", for: .normal)
//        self.leftViewMainLabel.attributedText = String.formatPriceLabel(
//            text: Formatters.sharedInstance.stringFromNumber(number: self.equityDetails!.open!)!,
//            priceSpacing: -5,
//            decimalSpacing: -2)
//        if let bidPrice = equityDetails?.bid, let askPrice = equityDetails?.ask {
//            let bidAskString = "Bid " + Formatters.sharedInstance.stringFromNumber(number: bidPrice)! + "  |  Ask " + Formatters.sharedInstance.stringFromNumber(number: askPrice)!
//            self.leftViewSubLabel.attributedText = String.formatDefaultLabel(text: bidAskString, spacing: -0.50)
//            self.leftViewSubLabel.textColor = UIColor.white
//        } else {
//            self.leftViewSubLabel.text = ""
//            self.leftViewSubLabel.textColor = UIColor.white
//        }
//    }
//    
//    func configureSecondStateLeftView() {
//        self.leftViewButton.setTitle("Market Cap", for: .normal)
//        self.leftViewMainLabel.attributedText = String.formatMarketCapLabel(text: (self.equityDetails?.marketCap)!,
//                                                                            numberSpacing: -5, textSpacing: -2)
//        if let peRatio = equityDetails?.priceEarningsRatio, let dividendYield = equityDetails?.dividendYield {
//            let bidAskString = "PE " + Formatters.sharedInstance.stringFromNumber(number: peRatio)! + "  |  Div Yield " + Formatters.sharedInstance.stringFromPercent(percent: dividendYield)!
//            self.leftViewSubLabel.attributedText = String.formatDefaultLabel(text: bidAskString, spacing: -0.50)
//            self.leftViewSubLabel.textColor = UIColor.white
//        } else {
//            self.leftViewSubLabel.text = ""
//            self.leftViewSubLabel.textColor = UIColor.white
//        }
//    }
//    
//    // Right View
//    
//    func configureDefaultStateRightView() {
//        self.rightViewButton.setTitle("Day's Range", for: .normal)
//        
//        if (equityDetails?.lastTradePrice != nil) && (equityDetails?.dailyLow != nil) && (equityDetails?.dailyHigh != nil) {
//            let dayRange = (equityDetails?.dailyHigh)! - (equityDetails?.dailyLow)!
//            let currentOverLow = (equityDetails?.lastTradePrice)! - (equityDetails?.dailyLow)!
//            let dayRangePercent = currentOverLow / dayRange
//            self.rightViewMainLabel.attributedText = String.formatDefaultLabel(text: Formatters.sharedInstance.stringFromFlatPercent(percent: dayRangePercent)!, spacing: -0.50)
//            circularProgressView.animate(fromAngle: 0, toAngle: dayRangePercent * 360, duration: 3) { completed in
//            }
//            if let lowPrice = equityDetails?.dailyLow, let highPrice = equityDetails?.dailyHigh {
//                let lowHighString = "L ↓ " + Formatters.sharedInstance.stringFromNumber(number: lowPrice)! + "  H ↑ " + Formatters.sharedInstance.stringFromNumber(number: highPrice)!
//                self.rightViewSubLabel.attributedText = String.formatDefaultLabel(text: lowHighString, spacing: -0.50)
//            } else {
//                self.rightViewSubLabel.text = ""
//            }
//            
//        } else {
//            self.rightViewMainLabel.text = ""
//            circularProgressView.angle = 0.0
//        }
//        
//    }
//    
//    func configureFirstStateRightView() {
//        self.rightViewButton.setTitle("52 Week Range", for: .normal)
//        if (equityDetails?.lastTradePrice != nil) && (equityDetails?.yearLow != nil) && (equityDetails?.yearHigh != nil) {
//            let dayRange = (equityDetails?.yearHigh)! - (equityDetails?.yearLow)!
//            let currentOverLow = (equityDetails?.lastTradePrice)! - (equityDetails?.yearLow)!
//            let yearRangePercent = currentOverLow / dayRange
//            self.rightViewMainLabel.attributedText = String.formatDefaultLabel(text: Formatters.sharedInstance.stringFromFlatPercent(percent: yearRangePercent)!, spacing: -0.50)
//            circularProgressView.animate(fromAngle: 0, toAngle: yearRangePercent * 360, duration: 3) { completed in
//            }
//            if let lowPrice = equityDetails?.yearLow, let highPrice = equityDetails?.yearHigh {
//                let lowHighString = "L ↓ " + Formatters.sharedInstance.stringFromNumber(number: lowPrice)! + "  H ↑ " + Formatters.sharedInstance.stringFromNumber(number: highPrice)!
//                self.rightViewSubLabel.attributedText = String.formatDefaultLabel(text: lowHighString, spacing: -0.50)
//            } else {
//                self.rightViewSubLabel.text = ""
//            }
//            
//        } else {
//            self.rightViewMainLabel.text = ""
//            circularProgressView.angle = 0.0
//        }
//        
//    }
//
//    func configureSecondStateRightView() {
//        self.rightViewButton.setTitle("% Avg Volume", for: .normal)
//        if (equityDetails?.currentVolume != nil) && (equityDetails?.averageDailyVolume != nil) {
//            if let currentVolume = equityDetails?.currentVolume, let averageDailyVolume = equityDetails?.averageDailyVolume {
//                let averageVolumePercent = Double(currentVolume) / Double(averageDailyVolume)
//                self.rightViewMainLabel.attributedText = String.formatDefaultLabel(text: Formatters.sharedInstance.stringFromFlatPercent(percent: averageVolumePercent)!, spacing: -1.50)
//                circularProgressView.animate(fromAngle: 0, toAngle: averageVolumePercent * 360, duration: 3) { completed in
//                }
//                let currentVolumeString = "Volume  " + Formatters.sharedInstance.stringFromInt(int: currentVolume)!
//                self.rightViewSubLabel.attributedText = String.formatDefaultLabel(text: currentVolumeString, spacing: -0.50)
//            }
//        } else {
//            self.rightViewMainLabel.text = ""
//            self.rightViewSubLabel.text = ""
//            circularProgressView.angle = 0.0
//            
//        }
//    }
//    
//    
//    
//    
//    
//    
//    
//    
//    
//}
