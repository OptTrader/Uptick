//
//  ChartFormatter.swift
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import Foundation
import Charts

public class ChartFormatter: NSObject, IAxisValueFormatter {
    
    open var sValues: [String]! = []
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return sValues[Int(value) % sValues.count]
    }
}
