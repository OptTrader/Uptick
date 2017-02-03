//
//  SearchApiClientProtocol.swift
//  Uptick
//
//  Created by Chris Kong on 1/24/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import Foundation

typealias SearchCallback = ([Search]) -> Void

protocol SearchApiClientProtocol {
    
    static func searchAsset(searchText: String,
                             onSuccess: SearchCallback?,
                             onError: ErrorCallback?
    )
}
