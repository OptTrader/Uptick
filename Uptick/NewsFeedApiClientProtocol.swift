//
//  NewsFeedApiClientProtocol.swift
//  Uptick
//
//  Created by Chris Kong on 1/24/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import Foundation

typealias NewsFeedCallback = ([NewsFeed]) -> Void

protocol NewsFeedApiClientProtocol {
    
    static func requestNewsFeedData(symbol: String,
                                          onSuccess: NewsFeedCallback?,
                                          onError: ErrorCallback?)
}
