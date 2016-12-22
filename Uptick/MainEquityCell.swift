//
//  MainEquityCell.swift
//  Uptick
//
//  Created by Chris Kong on 10/27/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import UIKit

protocol MainEquityCellTapPriceInfoDelegate: class {
    func tappedPriceInfo(cell: MainEquityCell)
}

class MainEquityCell: UITableViewCell {
    
    // MARK: Outlets & Properties
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var priceInfoLabel: UILabel!
    @IBOutlet weak var priceInformationView: UIView!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    var delegate: MainEquityCellTapPriceInfoDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapPriceInfoViewChange(_:)))
        priceInformationView.addGestureRecognizer(tapGesture)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureItem(state: Int, item: Equity) {
        // appearance
        symbolLabel?.textColor = ColorScheme.cellPrimaryTextColor
        companyNameLabel?.textColor = ColorScheme.cellSecondaryTextColor
        priceInfoLabel?.textColor = UIColor.white
        
        symbolLabel?.text = item.symbol
        companyNameLabel?.text = item.companyName
        priceInfoLabel?.text = Formatters.sharedInstance.stringFromPrice(
            price: item.lastTradePrice,
            currencyCode: "USD")
        
        configurePriceInfoView(state: state, item: item)
        
        let change = item.changeInPrice ?? 0.0
        
        switch change {
        case _ where change > 0.0:
            return priceInformationView.backgroundColor = ColorScheme.uptickViewColor
        case _ where change < 0.0:
            return priceInformationView.backgroundColor = ColorScheme.downtickViewColor
        default:
            return priceInformationView.backgroundColor = ColorScheme.flatTradeViewColor
        }
    }
    
    func configurePriceInfoView(state: Int, item: Equity) {
        let state = state
        switch state {
        case _ where state == 1:
            return (self.priceInfoLabel?.text = Formatters.sharedInstance.stringFromChangeNumber(number: item.changeInPrice))!
        case _ where state == 2:
            return (self.priceInfoLabel?.text = Formatters.sharedInstance.stringFromPercent(
                percent: item.changeInPercent))!
        default:
            return (self.priceInfoLabel?.text = Formatters.sharedInstance.stringFromPrice(
                price: item.lastTradePrice,
                currencyCode: "USD"))!
        }
    }
    
    func tapPriceInfoViewChange(_ sender: UITapGestureRecognizer) {
        delegate?.tappedPriceInfo(cell: self)
    }
    
}
