//
//  SearchEquityCell.swift
//  Uptick
//
//  Created by Chris Kong on 10/27/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import UIKit

protocol SearchEquityCellDelegate: class {
    func didAddButtonPressed(cell: SearchEquityCell)
}

class SearchEquityCell: UITableViewCell {

    // MARK: Outlets & Properties
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!

    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    var delegate: SearchEquityCellDelegate?
    
    var isAdded: Bool = false {
        didSet {
            if isAdded {
                addButton.setImage(UIImage(named: ImageView.check), for: .normal)
            } else {
                addButton.setImage(UIImage(named: ImageView.add), for: .normal)
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureItem(item: EquitySearch) {
        // appearance
        symbolLabel?.textColor = ColorScheme.cellPrimaryTextColor
        companyNameLabel?.textColor = ColorScheme.cellSecondaryTextColor
        
        symbolLabel?.text = item.symbol
        companyNameLabel?.text = item.companyName
        
        let symbols = UserDefaultsManagement.getTickers()
        if symbols.contains(item.symbol!) {
            isAdded = true
        } else {
            isAdded = false
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        delegate?.didAddButtonPressed(cell: self)
        isAdded = !isAdded
        if isAdded {
            addButton.setImage(UIImage(named: ImageView.check), for: .normal)
        } else {
            addButton.setImage(UIImage(named: ImageView.add), for: .normal)
        }
    }
    
    // MARK: Constants
    
    private struct ImageView {
        static let check = "check"
        static let add = "add"
    }
}
