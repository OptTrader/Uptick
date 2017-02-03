//
//  CurrencyApiClientProtocol.swift
//  Uptick
//
//  Created by Chris Kong on 1/25/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import Foundation

typealias CurrencyModelCallback = ([Currency]) -> Void
typealias CurrencyDetailsCallback = (CurrencyDetails) -> Void

protocol CurrencyApiProtocol {

    static func requestCurrencyData(currencies: Array<String>,
                                    onSuccess: CurrencyModelCallback?,
                                    onError: ErrorCallback?
    )
    
    static func requestCurrencyDetailsData(currency: String,
                                           onSuccess: CurrencyDetailsCallback?,
                                           onError: ErrorCallback?
    )

}
