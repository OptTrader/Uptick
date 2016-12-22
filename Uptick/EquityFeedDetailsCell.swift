//
//  EquityFeedDetailsCell.swift
//  Uptick
//
//  Created by Chris Kong on 12/6/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import UIKit

class EquityFeedDetailsCell: UITableViewCell {

    // MARK: Outlets & Properties
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
}
