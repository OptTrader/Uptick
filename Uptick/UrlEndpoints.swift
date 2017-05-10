//
//  UrlEndpoints.swift
//  Uptick
//
//  Created by Chris Kong on 1/24/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//  http://stackoverflow.com/questions/14795726/getting-data-from-yahoo-finance

import Foundation

class UrlEndpoints {
    
    // MARK: Multi-Assets Endpoint
    
    class func endpointForMultiQuotes(symbols: Array<String>) -> String {

        let symbolsString: String = symbols.joined(separator: "\", \"")

        let query = "select * from yahoo.finance.quotes where symbol in (\"\(symbolsString) \")&format=json&diagnostics=true&env=store://datatables.org/alltableswithkeys&callback="
//                let query = "select * from yahoo.finance.quotes where symbol in (\"\(symbolsString) \")&format=json&env=http://datatables.org/alltables.env"
        let encodedQuery = query.encodeUrl()
        
        let endpoint = "https://query.yahooapis.com/v1/public/yql?q=" + encodedQuery
        return endpoint
    }
    
    // MARK: Single Asset Endpoint
    
    class func endpointForAssetDetails(symbol: String) -> String {
                let query = "select * from yahoo.finance.quotes where symbol in (\"\(symbol) \")&format=json&diagnostics=true&env=store://datatables.org/alltableswithkeys&callback="
//        let query = "select * from yahoo.finance.quotes where symbol in (\"\(symbol) \")&format=json&env=http://datatables.org/alltables.env"
        let encodedQuery = query.encodeUrl()
        
        let endpoint = "https://query.yahooapis.com/v1/public/yql?q=" + encodedQuery
        return endpoint
    }
    
    // MARK: Chartpoints Endpoint
    
    class func endpointForAssetChartpoints(symbol: String, range: String) -> String {
        let query = "\(symbol)"
        let encodedQuery = query.encodeUrl()
        
        let endpoint = "https://chartapi.finance.yahoo.com/instrument/1.0/" + encodedQuery + "/chartdata;type=quote;range=\(range)/json"
        return endpoint
    }
    
    // MARK: NewsFeed Endpoint
    
    class func endpointForNewsFeed(symbol: String) -> String {
        let query = "\(symbol)"
        let encodedQuery = query.encodeUrl()
        
        let endpoint = "https://feeds.finance.yahoo.com/rss/2.0/headline?s=" + encodedQuery + "&region=US&lang=en-US&format=json"
        return endpoint
    }

}
