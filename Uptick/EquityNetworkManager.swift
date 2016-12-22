//
//  EquityNetworkManager
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import Foundation
import Alamofire
import AlamoFuzi
import SwiftyJSON

class EquityNetworkManager: EquityApiClientProtocol {

    // MARK: Build Equity Portfolio URL
    
    static func endpointForQuotes(symbols: Array<String>) -> String {
        
        let symbolsString: String = symbols.joined(separator: "\", \"")
        let query = "select * from yahoo.finance.quotes where symbol in (\"\(symbolsString) \")&format=json&env=http://datatables.org/alltables.env"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)
        
        let endpoint = "https://query.yahooapis.com/v1/public/yql?q=" + encodedQuery!
        return endpoint
    }
    
    static func requestEquityData(symbols: Array<String>, onSuccess: EquityModelCallback?, onError: ErrorCallback?) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlString = self.endpointForQuotes(symbols: symbols)
        Alamofire.request(urlString)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                // check for errors, tell caller if needed
                guard response.result.error == nil else {
                    print(response.result.error!)
                    onError?(APIManagerError.network(error: response.result.error!))
                    return
                }
                
                // make sure we got data & it's valid JSON
                guard let value = response.result.value else {
                    print("didn't get array of objects as JSON from API")
                    onError?(APIManagerError.objectSerialization(reason: "Did not get JSON dictionary in response"))
                    return
                }
                
                // convert JSON from responseJSON (uses NSJSONSerialization) to SwiftyJSON format for easier parsing
                let json = JSON(value)
                // Make sure the JSON is an array, like we expect (and not a dictionary)
                guard let jsonArray = json["query"]["results"]["quote"].array else {
                    print("JSON not parsed as expected array")
                    onError?(APIManagerError.jsonError(reason: "JSON parsing error"))
                    return
                }
                
                // Turn the JSON array into an array of Swift objects
                // assumes we have a Equity struct with an initializer that takes a jsonArray
                let stockQuotesArray = jsonArray.flatMap { Equity(json: $0) }
                onSuccess?(stockQuotesArray)
        }
    }
 
    // MARK: Equity Portfolio Network Call
    
    static func searchEquity(searchText: String, onSuccess: EquitySearchCallback?, onError: ErrorCallback?) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlString = "http://d.yimg.com/aq/autoc?query=\(searchText)&region=US&lang=en-US"
        Alamofire.request(urlString)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                // check for errors, tell caller if needed
                guard response.result.error == nil else {
                    print(response.result.error!)
                    onError?(APIManagerError.network(error: response.result.error!))
                    return
                }
                
                // make sure we got data & it's valid JSON
                guard let value = response.result.value else {
                    print("didn't get any search results as JSON from API")
                    onError?(APIManagerError.objectSerialization(reason: "Did not get JSON dictionary in response"))
                    return
                }
                
                let json = JSON(value)
                // Make sure the JSON is an array, like we expect (and not a dictionary)
                guard let jsonArray = json["ResultSet"]["Result"].array else {
                    print("JSON not parsed as expected array")
                    onError?(APIManagerError.jsonError(reason: "JSON parsing error"))
                    return
                }
                
                let searchArray = jsonArray.flatMap { EquitySearch(json: $0) }
                onSuccess?(searchArray)
        }
    }

    // MARK: Equity Charts Network Call

    static func requestEquityChartData(symbol: String, range: ChartRange, onSuccess: EquityChartpointCallback?, onError: ErrorCallback?) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlString = "http://chartapi.finance.yahoo.com/instrument/1.0/\(symbol)/chartdata;type=quote;range=\(range.rawValue)/json"
        Alamofire.request(urlString)
            .validate(statusCode: 200..<300)
            .responseData { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                // check for errors, tell caller if needed
                guard response.result.error == nil else {
                    print(response.result.error!)
                    onError?(APIManagerError.network(error: response.result.error!))
                    return
                }
                
                // make sure we got data
                guard response.result.value != nil else {
                    print("didn't get array of chartpoint objects as JSON from API")
                    onError?(APIManagerError.objectSerialization(reason: "Did not get JSON dictionary in response"))
                    return
                }
                
                // get the JSON payload
                if let data = response.result.value {
                    var jsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                    
                    // strip the wrapper
                    jsonString = jsonString.substring(from: 30) as NSString
                    jsonString = jsonString.substring(to: jsonString.length - 1) as NSString
                    
                    var js = NSData()
                    js = jsonString.data(using: String.Encoding.utf8.rawValue)! as NSData
                    
                    // parsing using SwiftyJSON
                    
                    let json = JSON(data: js as Data)
                    
                    let jsonArray = json["series"]
                    
                    // create array of data structures to hold return value
                    var stockChartpointsArray = [EquityChartpoint]()
                    
                    for (_, subJson) : (String, JSON) in jsonArray {
                        var chartpoint = EquityChartpoint()
                        
                        let dateInteger: Int
                        
                        switch range {
                        case .OneDay:
                            dateInteger = subJson["Timestamp"].int!
                            chartpoint.date = Formatters.sharedInstance.unixToHours(timestamp: Double(dateInteger))
                            
                        case .ThreeMonth, .OneYear, .FiveYear:
                            dateInteger = subJson["Date"].int!
                            let editedDateInt = dateInteger
                            let dateString = NSMutableString(string: "\(editedDateInt)")
                            dateString.insert("-", at: 4)
                            dateString.insert("-", at: 7)
                            chartpoint.date = Formatters.sharedInstance.dateFromString(key: dateString as String)
                        }
                        chartpoint.close = subJson["close"].double
                        chartpoint.high = subJson["high"].double
                        chartpoint.low = subJson["low"].double
                        chartpoint.open = subJson["open"].double
                        chartpoint.volume = subJson["volume"].int
                        stockChartpointsArray.append(chartpoint)
                    }
                    onSuccess?(stockChartpointsArray)
                }
        }
    }
    
    // MARK: Equity Details Network Call
    
    static func requestEquityDetailsData(symbol: String, onSuccess: EquityDetailsModelCallback?, onError: ErrorCallback?) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlString = self.endpointForQuotes(symbols: [symbol])
        Alamofire.request(urlString)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                // check for errors, tell caller if needed
                guard response.result.error == nil else {
                    print(response.result.error!)
                    onError?(APIManagerError.network(error: response.result.error!))
                    return
                }
                
                // make sure we got data & it's valid JSON
                guard let value = response.result.value else {
                    print("didn't get objects as JSON from API")
                    onError?(APIManagerError.objectSerialization(reason: "Did not get JSON in response"))
                    return
                }
                
                let json = JSON(value)
                let quoteJson = json["query"]["results"]["quote"]
                
                let equityDetails = EquityDetails(json: quoteJson)
                onSuccess?(equityDetails)
        }
    }
    
    // MARK: Equity News Feed Network Call
    
    static func requestEquityNewsFeedData(symbol: String, onSuccess: EquityNewsFeedCallback?, onError: ErrorCallback?) {
        
        let urlString = "https://feeds.finance.yahoo.com/rss/2.0/headline?s=\(symbol)&region=US&lang=en-US&format=json"
        Alamofire.request(urlString)
            .validate(statusCode: 200..<300)
            .responseXML { response in
                
                switch response.result {
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    onError?(APIManagerError.network(error: response.result.error!))
                case .success(let data):
                    
                    var feedArray = [EquityNewsFeed]()
                    
                    for item in data.css("item") {
                        var feed = EquityNewsFeed()
                        feed.currentTitle = (item.firstChild(css: "title")?.stringValue)!
                        feed.currentLink = (item.firstChild(css: "link")?.stringValue)!
                        let publishDateString = (item.firstChild(css: "pubDate")?.stringValue)!
                        let publishDate: Date = Formatters.sharedInstance.publishDateFromString(key: publishDateString)!
                        feed.sincePublishDate = Formatters.sharedInstance.timeSince(from: publishDate, numericDates: false)
                        
                        feedArray.append(feed)
                    }
                    onSuccess?(feedArray)
                }
        }
    }
    
    // MARK: StockTwits Network Call
    
    static func requestEquityTweetData(symbol: String, onSuccess: EquityTweetCallback?, onError: ErrorCallback?) {
        
        let urlString = "https://api.stocktwits.com/api/2/streams/symbol/\(symbol).json"
        Alamofire.request(urlString)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                
                // check for errors, tell caller if needed
                guard response.result.error == nil else {
                    print("No Response")
                    print(response.result.error!)
                    onError?(APIManagerError.network(error: response.result.error!))
                    return
                }
                
                // make sure we got data & it's valid JSON
                guard let value = response.result.value else {
                    print("didn't get array of objects as JSON from API")
                    onError?(APIManagerError.objectSerialization(reason: "Did not get JSON dictionary in response"))
                    return
                }
                
                let json = JSON(value)
                // Make sure the JSON is an array, like we expect (and not a dictionary)
                guard let jsonArray = json["messages"].array else {
                    print("JSON not parsed as expected array")
                    onError?(APIManagerError.jsonError(reason: "JSON parsing error"))
                    return
                }
//                print(jsonArray)
                let tweetsArray = jsonArray.flatMap { EquityTweet(json: $0) }
                onSuccess?(tweetsArray)
//                print(tweetsArray)
        }
    }
}
