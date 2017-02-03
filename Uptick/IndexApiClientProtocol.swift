//
//  IndexApiClientProtocol.swift
//  Uptick
//
//  Created by Chris Kong on 1/25/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import Foundation

typealias IndexModelCallback = ([Index]) -> Void
typealias IndexDetailsCallback = (IndexDetails) -> Void

protocol IndexApiProtocol {

    static func requestIndexData(indices: Array<String>,
                                 onSuccess: IndexModelCallback?,
                                 onError: ErrorCallback?
    )
    
    static func requestIndexDetailsData(index: String,
                                        onSuccess: IndexDetailsCallback?,
                                        onError: ErrorCallback?
    )

}
