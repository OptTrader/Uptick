//
//  Formatters.swift
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import Foundation

public class Formatters {
    public static let sharedInstance = Formatters()
    
    private let displayDateFormatter = DateFormatter()
    private let dateFormatter = DateFormatter()
    private let publishDateFormatter = DateFormatter()
    private let createDateFormatter = DateFormatter()
    private let dateKeyFormatter = DateFormatter()
    private let timeKeyFormatter = DateFormatter()
    private let percentFormatter = NumberFormatter()
    private let flatPercentFormatter = NumberFormatter()
    private let currencyFormatter = NumberFormatter()
    private let numberFormatter = NumberFormatter()
    private let numberChangeFormatter = NumberFormatter()
    private let intFormatter = NumberFormatter()
    private let largeNumberFormatter = NumberFormatter()
    
    init() {
        displayDateFormatter.dateFormat = "MMM yyyy"
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        publishDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        publishDateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZZZ"
        createDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        createDateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        createDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateKeyFormatter.locale = Locale.current
        dateKeyFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateKeyFormatter.dateFormat = "yyyy-MM-dd"
        timeKeyFormatter.locale = Locale.current
        timeKeyFormatter.timeZone = TimeZone(abbreviation: "EDT")
        timeKeyFormatter.dateFormat = "h:mm a"
        percentFormatter.numberStyle = .percent
        percentFormatter.minimumFractionDigits = 2
        flatPercentFormatter.numberStyle = .percent
        flatPercentFormatter.minimumFractionDigits = 0
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.minimumFractionDigits = 2
        currencyFormatter.minimumIntegerDigits = 1
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.minimumIntegerDigits = 1
        numberChangeFormatter.usesGroupingSeparator = true
        numberChangeFormatter.maximumFractionDigits = 2
        numberChangeFormatter.minimumFractionDigits = 2
        numberChangeFormatter.minimumIntegerDigits = 1
        numberChangeFormatter.positivePrefix = numberChangeFormatter.plusSign
        intFormatter.usesGroupingSeparator = true
        intFormatter.numberStyle = .decimal
        intFormatter.minimumIntegerDigits = 1
        largeNumberFormatter.usesGroupingSeparator = true
    }
    
    public func dateFromString(key: String?) -> Date? {
        guard let key = key else { return nil }
        return dateKeyFormatter.date(from: key)
    }
    
    public func publishDateFromString(key: String?) -> Date? {
        guard let key = key else { return nil }
        return publishDateFormatter.date(from: key)
    }
    
    public func createDateFromString(key: String?) -> Date? {
        guard let key = key else { return nil }
        return createDateFormatter.date(from: key)
    }
    
    public func stringFromDate(date: Date?) -> String? {
        guard let date = date else { return nil }
        return dateKeyFormatter.string(from: date)
    }
    
    public func unixToHours(timestamp: Double?) -> Date? {
        guard let timestamp = timestamp else { return nil }
        return Date(timeIntervalSince1970: timestamp)
    }
    
    public func stringFromHours(date: Date?) -> String? {
        guard let date = date else { return nil }
        return timeKeyFormatter.string(from: date)
    }
    
    public func stringFromPrice(price: Double?, currencyCode: String) -> String? {
        guard let price = price else { return nil }
        currencyFormatter.currencyCode = currencyCode
        return currencyFormatter.string(from: NSNumber(value: price))
    }
    
    public func stringFromPercent(percent: Double?) -> String? {
        guard let percent = percent else { return nil }
        return percentFormatter.string(from: NSNumber(value: percent))
    }
    
    public func stringFromFlatPercent(percent: Double?) -> String? {
        guard let percent = percent else { return nil }
        return flatPercentFormatter.string(from: NSNumber(value: percent))
    }
    
    public func stringFromNumber(number: Double?) -> String? {
        guard let number = number else { return nil }
        return numberFormatter.string(from: NSNumber(value: number))
    }
    
    public func stringFromChangeNumber(number: Double?) -> String? {
        guard let number = number else { return nil }
        return numberChangeFormatter.string(from: NSNumber(value: number))
    }
    
    public func stringFromInt(int: Int?) -> String? {
        guard let int = int else { return nil }
        return intFormatter.string(from: NSNumber(value: int))
    }
    
    public func stringFromLargeNumber(numberString: String?) -> String? {
        guard let numberString = numberString,
            let number = Double(numberString) else { return nil }
        return largeNumberFormatter.string(from: NSNumber(value: number))
    }
    
    public func timeSince(from: Date, numericDates: Bool = false) -> String {
        let calendar = Calendar.current
        let now = NSDate()
        let earliest = now.earlierDate(from as Date)
        let latest = earliest == now as Date ? from : now as Date
        let components = calendar.dateComponents([.year, .weekOfYear, .month, .day, .hour, .minute, .second], from: earliest, to: latest as Date)
        
        var result = ""
        
        if components.year! >= 2 {
            result = "\(components.year!) years ago"
        } else if components.year! >= 1 {
            if numericDates {
                result = "1 year ago"
            } else {
                result = "Last year"
            }
        } else if components.month! >= 2 {
            result = "\(components.month!) months ago"
        } else if components.month! >= 1 {
            if numericDates {
                result = "1 month ago"
            } else {
                result = "Last month"
            }
        } else if components.weekOfYear! >= 2 {
            result = "\(components.weekOfYear!) weeks ago"
        } else if components.weekOfYear! >= 1 {
            if numericDates {
                result = "1 week ago"
            } else {
                result = "Last week"
            }
        } else if components.day! >= 2 {
            result = "\(components.day!) days ago"
        } else if components.day! >= 1 {
            if numericDates {
                result = "1 day ago"
            } else {
                result = "Yesterday"
            }
        } else if components.hour! >= 2 {
            result = "\(components.hour!) hours ago"
        } else if components.hour! >= 1 {
            if numericDates {
                result = "1 hour ago"
            } else {
                result = "An hour ago"
            }
        } else if components.minute! >= 2 {
            result = "\(components.minute!) minutes ago"
        } else if components.minute! >= 1 {
            if numericDates {
                result = "1 minute ago"
            } else {
                result = "A minute ago"
            }
        } else if components.second! >= 3 {
            result = "\(components.second!) seconds ago"
        } else {
            result = "Just now"
        }
        
        return result
    }
    
}
