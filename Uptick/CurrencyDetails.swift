//
//  CurrencyDetails.swift
//  Uptick
//
//  Created by Chris Kong on 1/25/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import Foundation
import SwiftyJSON

struct CurrencyDetails {
    var name: String?
    var symbolForStockTwits: String?
    var lastTradePrice: Float?
    var previousClosePrice: Float?
    var changeInPrice: Float?
    var changeInPercent: Double?
    var ask: Float?
    var bid: Float?
    var open: Float?
    var dailyHigh: Float?
    var dailyLow: Float?
    var yearHigh: Float?
    var yearLow: Float?
    
}

extension CurrencyDetails {
    init(json: JSON) {
        self.name = json["Name"].stringValue
        if (self.name) != nil {
            self.symbolForStockTwits = self.name?.removeSlashCharacter()
        }
        self.lastTradePrice = json["LastTradePriceOnly"].floatValue
        self.previousClosePrice = json["PreviousClose"].floatValue
        self.changeInPrice = json["Change"].floatValue
        if (self.changeInPrice != nil) && (self.previousClosePrice != nil) {
            self.changeInPercent = Double(self.changeInPrice! / self.previousClosePrice!)
        } else {
            self.changeInPercent = 0.00
        }
        self.ask = json["Ask"].floatValue
        self.bid = json["Bid"].floatValue
        self.open = json["Open"].floatValue
        self.dailyHigh = json["DaysHigh"].floatValue
        self.dailyLow = json["DaysLow"].floatValue
        self.yearHigh = json["YearHigh"].floatValue
        self.yearLow = json["YearLow"].floatValue
    }
}
