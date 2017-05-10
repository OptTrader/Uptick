//
//  EquityNetworkManager.swift
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import Foundation
import Alamofire
import AlamoFuzi
import SwiftyJSON

class EquityNetworkManager: EquityApiClientProtocol, ChartpointApiClientProtocol, NewsFeedApiClientProtocol, TweetApiClientProtocol {
    
    // MARK: Equity Portfolio Network Call
    
    static func requestEquityData(symbols: Array<String>, onSuccess: EquityModelCallback?, onError: ErrorCallback?) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlString = UrlEndpoints.endpointForMultiQuotes(symbols: symbols)
        Alamofire.request(urlString)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                guard response.result.error == nil else {
                    print(response.result.error!)
                    onError?(APIManagerError.network(error: response.result.error!))
                    return
                }
                
                guard let value = response.result.value else {
                    print("didn't get array of objects as JSON from API")
                    onError?(APIManagerError.objectSerialization(reason: "Did not get JSON dictionary in response"))
                    return
                }
                
                let json = JSON(value)
                guard let jsonArray = json["query"]["results"]["quote"].array else {
                    print("JSON not parsed as expected array")
                    onError?(APIManagerError.jsonError(reason: "JSON parsing error"))
                    return
                }
                
                let stockQuotesArray = jsonArray.flatMap { Equity(json: $0) }
                onSuccess?(stockQuotesArray)
        }
    }
    
    // MARK: Equity Details Network Call
    
    static func requestEquityDetailsData(symbol: String, onSuccess: EquityDetailsModelCallback?, onError: ErrorCallback?) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlString = UrlEndpoints.endpointForAssetDetails(symbol: symbol)
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
 
    // MARK: Equity Charts Network Call

    static func requestChartData(symbol: String, range: ChartRange, onSuccess: ChartpointCallback?, onError: ErrorCallback?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlString = UrlEndpoints.endpointForAssetChartpoints(symbol: symbol, range: range.rawValue)
        
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
                    var chartpointsArray = [Chartpoint]()
                    
                    for (_, subJson) : (String, JSON) in jsonArray {
                        var chartpoint = Chartpoint()
                        
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
//                        chartpoint.volume = subJson["volume"].int
                        chartpointsArray.append(chartpoint)
                    }
                    onSuccess?(chartpointsArray)
                }
        }
    }
        
    // MARK: Equity News Feed Network Call
    
    static func requestNewsFeedData(symbol: String, onSuccess: NewsFeedCallback?, onError: ErrorCallback?) {
        let urlString = UrlEndpoints.endpointForNewsFeed(symbol: symbol)
        Alamofire.request(urlString)
            .validate(statusCode: 200..<300)
            .responseXML { response in
                
                switch response.result {
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    onError?(APIManagerError.network(error: response.result.error!))
                case .success(let data):
                    
                    var feedArray = [NewsFeed]()
                    
                    for item in data.css("item") {
                        var feed = NewsFeed()
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
    
    static func requestTweetData(symbol: String, onSuccess: TweetCallback?, onError: ErrorCallback?) {
        
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
                
                let tweetsArray = jsonArray.flatMap { Tweet(json: $0) }
                onSuccess?(tweetsArray)
        }
    }

}
