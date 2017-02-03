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
    var companyName: String?
    var lastTradePrice: Double?
    var previousClosePrice: Double?
    var changeInPrice: Double?
    var changeInPercent: Double?
    var bid: Double?
    var ask: Double?
    var open: Double?
    var currentVolume: Int?
    var averageDailyVolume: Int?
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
        self.companyName = json["Name"].stringValue
        self.lastTradePrice = json["LastTradePriceOnly"].doubleValue
        self.previousClosePrice = json["PreviousClose"].doubleValue
        self.changeInPrice = json["Change"].doubleValue
        if (self.changeInPrice != nil) && (self.previousClosePrice != nil) {
            self.changeInPercent = self.changeInPrice! / self.previousClosePrice!
        } else {
            self.changeInPercent = 0.00
        }
        self.bid = json["Bid"].doubleValue
        self.ask = json["Ask"].doubleValue
        self.open = json["Open"].doubleValue
        self.currentVolume = json["Volume"].intValue
        self.averageDailyVolume = json["AverageDailyVolume"].intValue
        self.dailyHigh = json["DaysHigh"].doubleValue
        self.dailyLow = json["DaysLow"].doubleValue
        self.yearHigh = json["YearHigh"].doubleValue
        self.yearLow = json["YearLow"].doubleValue
        self.marketCap = json["MarketCapitalization"].stringValue
        self.priceEarningsRatio = json["PERatio"].doubleValue
        self.dividendYield = json["DividendYield"].doubleValue / 100.00
    }
}
