//
//  IndexDetails.swift
//  Uptick
//
//  Created by Chris Kong on 1/25/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import Foundation
import SwiftyJSON

struct IndexDetails {
    var lastTradePrice: Double?
    var previousClosePrice: Double?
    var changeInPrice: Double?
    var changeInPercent: Double?
    var ask: Double?
    var bid: Double?
    var open: Double?
    var volume: Int?
    var dailyHigh: Double?
    var dailyLow: Double?
    var yearHigh: Double?
    var yearLow: Double?
}

extension IndexDetails {
    init(json: JSON) {
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
        self.volume = json["Volume"].intValue
        self.dailyHigh = json["DaysHigh"].doubleValue
        self.dailyLow = json["DaysLow"].doubleValue
        self.yearHigh = json["YearHigh"].doubleValue
        self.yearLow = json["YearLow"].doubleValue
    }
}
