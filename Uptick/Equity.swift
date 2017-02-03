//
//  Equity.swift
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import Foundation
import SwiftyJSON
import Pantry

struct Equity {
    var companyName: String?
    var symbol: String?
    var lastTradePrice: Double?
    var previousClosePrice: Double?
    var changeInPrice: Double?
    var changeInPercent: Double?
}

extension Equity {
    init(json: JSON) {
        self.companyName = json["Name"].stringValue
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

extension Equity: Storable {
    init?(warehouse: Warehouseable) {
        self.companyName = warehouse.get(PropertyKey.companyNameKey) ?? ""
        self.symbol = warehouse.get(PropertyKey.symbolKey) ?? ""
        self.lastTradePrice = warehouse.get(PropertyKey.lastTradePriceKey) ?? 0.0
        self.changeInPrice = warehouse.get(PropertyKey.changeInPriceKey) ?? 0.0
        self.changeInPercent = warehouse.get(PropertyKey.changeInPercentKey) ?? 0.0
    }
    
    func toDictionary() -> [String : Any] {
        return [PropertyKey.companyNameKey : self.companyName ?? "",
                PropertyKey.symbolKey : self.symbol ?? "",
                PropertyKey.lastTradePriceKey : self.lastTradePrice ?? 0.0,
                PropertyKey.changeInPriceKey : self.changeInPrice ?? 0.0,
                PropertyKey.changeInPercentKey : self.changeInPercent ?? 0.0
        ]
    }
    
    struct PropertyKey {
        static let companyNameKey = "companyName"
        static let symbolKey = "symbol"
        static let lastTradePriceKey = "lastTradePrice"
        static let changeInPriceKey = "changeInPrice"
        static let changeInPercentKey = "changeInPercent"
    }
}
