//
//  NewsFeed.swift
//  Uptick
//
//  Created by Chris Kong on 1/24/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import Foundation

struct NewsFeed {
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

extension NewsFeed {
    init(_ title: String, _ link: String, _ sincePublishDate: String) {
        self.currentTitle = title
        self.currentLink = link
        self.sincePublishDate = sincePublishDate
    }
}
