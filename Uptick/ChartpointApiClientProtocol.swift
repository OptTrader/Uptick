//
//  ChartpointApiClientProtocol.swift
//  Uptick
//
//  Created by Chris Kong on 1/24/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import Foundation

typealias ChartpointCallback = ([Chartpoint]) -> Void

protocol ChartpointApiClientProtocol {
    
    static func requestChartData(symbol: String,
                                       range: ChartRange,
                                       onSuccess: ChartpointCallback?,
                                       onError: ErrorCallback?
    )
}
