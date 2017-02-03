//
//  UserDefaultsManagement.swift
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//  http://stackoverflow.com/questions/25420651/store-string-in-nsuserdefaults-swift

import Foundation

public class UserDefaultsManagement {
    
    // MARK: Stocks
    
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
    
    // MARK: Currencies
    
    public class func getCurrencies() -> [String] {
        let userDefaults = UserDefaults.standard
        var currencies: [String] {
            get {
                if let returnValue = userDefaults.object(forKey: Constants.UserDefaultsFavoriteCurrencies) {
                    return returnValue as! [String]
                } else {
                    return ["EURUSD=X", "JPY=X", "GBPUSD=X", "AUDUSD=X", "NZDUSD=X", "EURJPY=X", "GBPJPY=X", "EURGBP=X", "CNY=X"]
                }
            }
            set {
                userDefaults.set(newValue, forKey: Constants.UserDefaultsFavoriteCurrencies)
                userDefaults.synchronize()
            }
        }
        return currencies
    }
    
    public class func saveCurrencies(currencies: [String]) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(currencies, forKey: Constants.UserDefaultsFavoriteCurrencies)
        userDefaults.synchronize()
    }
    
    public class func deleteCurrency(currency: String) {
        var currencies: [String] = self.getCurrencies()
        currencies.remove(at: currencies.index(of: currency)!)
        self.saveCurrencies(currencies: currencies)
    }
    
    // MARK: Indices
    
    public class func getIndices() -> [String] {
        let userDefaults = UserDefaults.standard
        var indices: [String] {
            get {
                if let returnValue = userDefaults.object(forKey: Constants.UserDefaultsFavoriteIndices) {
                    return returnValue as! [String]
                } else {
                    return ["^GSPC", "^IXIC", "^FTSE", "^N225"]
                }
            }
            set {
                userDefaults.set(newValue, forKey: Constants.UserDefaultsFavoriteIndices)
                userDefaults.synchronize()
            }
        }
        return indices
    }
    
    // Save & Delete Index??
    
    public class func getIndicesDictionary() -> [String: String] {
        let userDefaults = UserDefaults.standard
        var indicesDictionary: [String: String] {
            get {
                if let returnValue = userDefaults.object(forKey: Constants.USerDefaultsIndicesDictionary) {
                    return returnValue as! [String: String]
                } else {
                    return ["^GSPC" : "SPX", "^IXIC" : "COMPQ", "^FTSE" : "FTSE", "^N225" : "NIKKEI"]
                }
            }
            set {
                userDefaults.set(newValue, forKey: Constants.USerDefaultsIndicesDictionary)
                userDefaults.synchronize()
            }
        }
        return indicesDictionary
    }
    
    // MARK: Constants
    
    private struct Constants {
        static let UserDefaultsFavoriteStocks = "favoriteStocks"
        static let UserDefaultsFavoriteCurrencies = "favoriteCurrencies"
        static let UserDefaultsFavoriteIndices = "favoriteIndices"
        static let USerDefaultsIndicesDictionary = "indicesDictionary"
    }
}
