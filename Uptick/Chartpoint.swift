//
//  Chartpoint.swift
//  Uptick
//
//  Created by Chris Kong on 1/24/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import Foundation

public enum ChartRange: String {
    case OneDay = "1d"
    case ThreeMonth = "3m"
    case OneYear = "1y"
    case FiveYear = "5y"
}

struct Chartpoint {
    var date: Date?
    var close: Double?
    var high: Double?
    var low: Double?
    var open: Double?
}
