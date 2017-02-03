//
//  Currency.swift
//  Uptick
//
//  Created by Chris Kong on 1/25/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Currency {
    var name: String?
    var symbol: String?
    var lastTradePrice: Float?
    var previousClosePrice: Float?
    var changeInPrice: Float?
    var changeInPercent: Double?
    var ask: Float?
    var bid: Float?
}

extension Currency {
    init(json: JSON) {
        self.name = json["Name"].stringValue
        self.symbol = json["Symbol"].stringValue
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
    }
}
