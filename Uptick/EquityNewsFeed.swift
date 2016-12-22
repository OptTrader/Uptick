//
//  EquityNewsFeed.swift
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import Foundation
import Pantry

struct EquityNewsFeed {
    var currentTitle: String = "" {
        didSet {
            currentTitle = currentTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    var currentLink: String = "" {
        didSet {
            currentLink = currentLink.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    var sincePublishDate: String = ""
}

extension EquityNewsFeed {
    init(_ title: String, _ link: String, _ sincePublishDate: String) {
        self.currentTitle = title
        self.currentLink = link
        self.sincePublishDate = sincePublishDate
    }
}

//extension EquityNewsFeed: Pantry {
//    
//}
