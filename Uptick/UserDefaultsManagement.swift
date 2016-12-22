//
//  UserDefaultsManagement.swift
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//  http://stackoverflow.com/questions/25420651/store-string-in-nsuserdefaults-swift

import Foundation

public class UserDefaultsManagement {
    
    // MARK: Methods
    
    public class func getTickers() -> [String] {
        let userDefaults = UserDefaults.standard
        var tickers: [String] {
            get {
                if let returnValue = userDefaults.object(forKey: Constants.UserDefaultsFavoriteStocks) {
                    return returnValue as! [String]
                } else {
                    return ["AAPL", "GOOG", "TSLA", "SBUX", "MSFT", "FB", "TWTR", "BABA", "AMZN", "NFLX", "EBAY"]
                }
            }
            set {
                userDefaults.set(newValue, forKey: Constants.UserDefaultsFavoriteStocks)
                userDefaults.synchronize()
            }
        }
        return tickers
    }
    
    public class func saveTickers(tickers: [String]) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(tickers, forKey: Constants.UserDefaultsFavoriteStocks)
        userDefaults.synchronize()
    }
    
    public class func deleteTicker(ticker: String) {
        var tickers: [String] = self.getTickers()
        tickers.remove(at: tickers.index(of: ticker)!)
        self.saveTickers(tickers: tickers)
    }
    
    // MARK: Constants
    
    private struct Constants {
        static let UserDefaultsFavoriteStocks = "favoriteStocks"
    }
}
