//
//  EquityDetailsCollectionViewCell.swift
//  Uptick
//
//  Created by Chris Kong on 10/30/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import UIKit

class EquityDetailsCollectionViewCell: UICollectionViewCell {

    // MARK: Outlets & Properties
    
    @IBOutlet weak var fieldLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    func configureItem(indexPath: Int, item: EquityDetails) {
        fieldLabel?.textColor = ColorScheme.cellSecondaryTextColor
        valueLabel?.textColor = ColorScheme.cellPrimaryTextColor
        
        switch indexPath {
            case 0:
                fieldLabel?.text = "Bid"
                valueLabel?.text = Formatters.sharedInstance.stringFromNumber(number: item.bid) ?? "0.0"
            case 1:
                fieldLabel?.text = "Ask"
                valueLabel?.text = Formatters.sharedInstance.stringFromNumber(number: item.ask) ?? "0.0"
            case 2:
                fieldLabel?.text = "Open"
                valueLabel?.text = Formatters.sharedInstance.stringFromNumber(number: item.open) ?? "0.0"
            case 3:
                fieldLabel?.text = "Volume"
                // REFORMAT VOLUME UNDER AND OVER 1MM??
                valueLabel?.text = Formatters.sharedInstance.stringFromInt(int: item.volume) ?? "0.0"
            case 4:
                fieldLabel?.text = "High"
                valueLabel?.text = Formatters.sharedInstance.stringFromNumber(number: item.dailyHigh) ?? "0.0"
            case 5:
                fieldLabel?.text = "% Avg Vol."
                valueLabel?.text = Formatters.sharedInstance.stringFromPercent(percent: item.percentOfAverageVolume) ?? "0.0%"
            case 6:
                fieldLabel?.text = "Low"
                valueLabel?.text = Formatters.sharedInstance.stringFromNumber(number: item.dailyLow) ?? "0.0"
            case 7:
                fieldLabel?.text = "Mkt Cap"
                valueLabel?.text = item.marketCap ?? "N/A"
            case 8:
                fieldLabel?.text = "52w High"
                valueLabel?.text = Formatters.sharedInstance.stringFromNumber(number: item.yearHigh) ?? "0.0"
            case 9:
                fieldLabel?.text = "P/E Ratio"
                valueLabel?.text = Formatters.sharedInstance.stringFromNumber(number: item.priceEarningsRatio) ?? "N/A"
            case 10:
                fieldLabel?.text = "52w Low"
                valueLabel?.text = Formatters.sharedInstance.stringFromNumber(number: item.yearLow) ?? "0.0"
            case 11:
                fieldLabel?.text = "Div Yield"
                valueLabel?.text = Formatters.sharedInstance.stringFromPercent(percent: item.dividendYield) ?? "0.0%"
            
            default:
                fieldLabel?.text = ""
                valueLabel?.text = ""
        }
    }

}
