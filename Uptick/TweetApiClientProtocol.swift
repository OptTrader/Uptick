//
//  TweetApiClientProtocol.swift
//  Uptick
//
//  Created by Chris Kong on 1/24/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import Foundation

typealias TweetCallback = ([Tweet]) -> Void

protocol TweetApiClientProtocol {
    
    static func requestTweetData(symbol: String,
                                       onSuccess: TweetCallback?,
                                       onError: ErrorCallback?)
}
