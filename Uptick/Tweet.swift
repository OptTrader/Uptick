//
//  Tweet.swift
//  Uptick
//
//  Created by Chris Kong on 1/24/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Tweet {
    var userName: String?
    var name: String?
    var avatarUrl: String?
    var tweet: String?
    var sinceCreated: String?
//    var title: String?
//    var imageUrl: String?
}

extension Tweet {
    init(json: JSON) {
        self.userName = json["user"]["username"].stringValue
        self.name = json["user"]["name"].stringValue
        self.avatarUrl = json["user"]["avatar_url"].stringValue
        let tweetString = json["body"].stringValue.replacingOccurrences(of: "&#39;", with: "'").replacingOccurrences(of: "&quot;", with: "'").replacingOccurrences(of: "&amp;", with: "&")
        self.tweet = tweetString.replacingOccurrences(of: "\'", with: "'", options: String.CompareOptions.literal, range: nil)
        let createdAtString = json["created_at"].stringValue
        if let dateFromString = Formatters.sharedInstance.createDateFromString(key: createdAtString) {
            self.sinceCreated = Formatters.sharedInstance.timeSince(from: dateFromString, numericDates: false)
        }
//        self.title = json["links"]["title"].stringValue
//        self.imageUrl = json["links"]["image"].stringValue
    }
}
