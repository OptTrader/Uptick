//
//  EquityDetails.swift
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import Foundation
import SwiftyJSON
import Pantry

struct EquityDetails {
    var lastTradePrice: Double?
    var previousClosePrice: Double?
    var changeInPrice: Double?
    var changeInPercent: Double?
    var bid: Double?
    var ask: Double?
    var open: Double?
    var volume: Int?
    var percentOfAverageVolume: Double?
    var dailyHigh: Double?
    var dailyLow: Double?
    var yearHigh: Double?
    var yearLow: Double?
    var marketCap: String?
    var priceEarningsRatio: Double?
    var dividendYield: Double?
}

extension EquityDetails {
    init(json: JSON) {
        self.lastTradePrice = json["LastTradePriceOnly"].doubleValue
        self.previousClosePrice = json["PreviousClose"].doubleValue
        self.changeInPrice = json["Change"].doubleValue
        self.changeInPercent = self.changeInPrice! / self.previousClosePrice!
        self.bid = json["Bid"].doubleValue
        self.ask = json["Ask"].doubleValue
        self.open = json["Open"].doubleValue
        self.volume = json["Volume"].intValue
        let averageDailyVolume = json["AverageDailyVolume"].intValue
        
        if (self.volume != nil) && averageDailyVolume > 0 {
            self.percentOfAverageVolume = Double(volume! / averageDailyVolume)
        } else {
            self.percentOfAverageVolume = 0.00
        }

//        self.percentOfAverageVolume = Double(volume! / averageDailyVolume)
        self.dailyHigh = json["DaysHigh"].doubleValue
        self.dailyLow = json["DaysLow"].doubleValue
        self.yearHigh = json["YearHigh"].doubleValue
        self.yearLow = json["YearLow"].doubleValue
        self.marketCap = json["MarketCapitalization"].stringValue
        self.priceEarningsRatio = json["PERatio"].doubleValue
        self.dividendYield = json["DividendYield"].doubleValue / 100.00
    }
}
