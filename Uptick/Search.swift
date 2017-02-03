//
//  Search.swift
//  Uptick
//
//  Created by Chris Kong on 1/24/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Search {
    var companyName: String?
    var symbol: String?
    var assetType: String?
    var isAdded = false
}

extension Search {
    init(json: JSON) {
        self.companyName = json["name"].stringValue
        self.symbol = json["symbol"].stringValue
        self.assetType = json["typeDisp"].stringValue
    }
}
