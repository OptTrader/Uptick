//
//  SearchNetworkManager.swift
//  Uptick
//
//  Created by Chris Kong on 1/24/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SearchNetworkManager: SearchApiClientProtocol {
    
    // MARK: Equity Search Network Call
    
    static func searchAsset(searchText: String, onSuccess: SearchCallback?, onError: ErrorCallback?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlString = "http://d.yimg.com/aq/autoc?query=\(searchText)&region=US&lang=en-US"
        Alamofire.request(urlString)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                // check for errors, tell caller if needed
                guard response.result.error == nil else {
                    print(response.result.error!)
                    onError?(APIManagerError.network(error: response.result.error!))
                    return
                }
                
                // make sure we got data & it's valid JSON
                guard let value = response.result.value else {
                    print("didn't get any search results as JSON from API")
                    onError?(APIManagerError.objectSerialization(reason: "Did not get JSON dictionary in response"))
                    return
                }
                
                let json = JSON(value)
                // Make sure the JSON is an array, like we expect (and not a dictionary)
                guard let jsonArray = json["ResultSet"]["Result"].array else {
                    print("JSON not parsed as expected array")
                    onError?(APIManagerError.jsonError(reason: "JSON parsing error"))
                    return
                }
                
                let searchArray = jsonArray.flatMap { Search(json: $0) }
                onSuccess?(searchArray)
        }
    }
}
