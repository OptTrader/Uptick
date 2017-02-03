//
//  Index.swift
//  Uptick
//
//  Created by Chris Kong on 1/25/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Index {
    var name: String?
    var symbol: String?
    var lastTradePrice: Double?
    var previousClosePrice: Double?
    var changeInPrice: Double?
    var changeInPercent: Double?
}

extension Index {
    init(json: JSON) {
        self.name = json["Name"].stringValue
        self.symbol = json["Symbol"].stringValue
        self.lastTradePrice = json["LastTradePriceOnly"].doubleValue
        self.previousClosePrice = json["PreviousClose"].doubleValue
        self.changeInPrice = json["Change"].doubleValue
        if (self.changeInPrice != nil) && (self.previousClosePrice != nil) {
            self.changeInPercent = self.changeInPrice! / self.previousClosePrice!
        } else {
            self.changeInPercent = 0.00
        }
    }
}
