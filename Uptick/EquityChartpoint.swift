//
//  EquityChartpoint.swift
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import Foundation

public enum ChartRange: String {
    case OneDay = "1d"
    case ThreeMonth = "3m"
    case OneYear = "1y"
    case FiveYear = "5y"
}

struct EquityChartpoint {
    var date: Date?
    var close: Double?
    var high: Double?
    var low: Double?
    var open: Double?
    var volume: Int?
}
