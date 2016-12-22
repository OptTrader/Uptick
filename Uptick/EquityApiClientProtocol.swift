//
//  EquityApiClientProtocol
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import Foundation

typealias EquityModelCallback = ([Equity]) -> Void
typealias EquitySearchCallback = ([EquitySearch]) -> Void
typealias EquityChartpointCallback = ([EquityChartpoint]) -> Void
typealias EquityDetailsModelCallback = (EquityDetails) -> Void
typealias EquityNewsFeedCallback = ([EquityNewsFeed]) -> Void
typealias EquityTweetCallback = ([EquityTweet]) -> Void

typealias ErrorCallback = (Error) -> Void

protocol EquityApiClientProtocol {
    
    static func requestEquityData(symbols: Array<String>,
                                  onSuccess: EquityModelCallback?,
                                  onError: ErrorCallback?
    )
    
    static func searchEquity(searchText: String,
                             onSuccess: EquitySearchCallback?,
                             onError: ErrorCallback?
    )
    
    static func requestEquityChartData(symbol: String,
                                       range: ChartRange,
                                       onSuccess: EquityChartpointCallback?,
                                       onError: ErrorCallback?
    )
    
    static func requestEquityDetailsData(symbol: String,
                                         onSuccess: EquityDetailsModelCallback?,
                                         onError: ErrorCallback?)
    
    static func requestEquityNewsFeedData(symbol: String,
                                          onSuccess: EquityNewsFeedCallback?,
                                          onError: ErrorCallback?)
    
    static func requestEquityTweetData(symbol: String,
                                       onSuccess: EquityTweetCallback?,
                                       onError: ErrorCallback?)
    
}
