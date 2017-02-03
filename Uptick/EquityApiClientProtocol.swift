//
//  EquityApiClientProtocol
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import Foundation

typealias EquityModelCallback = ([Equity]) -> Void
typealias EquityDetailsModelCallback = (EquityDetails) -> Void

protocol EquityApiClientProtocol {
    
    static func requestEquityData(symbols: Array<String>,
                                  onSuccess: EquityModelCallback?,
                                  onError: ErrorCallback?
    )
    
    static func requestEquityDetailsData(symbol: String,
                                         onSuccess: EquityDetailsModelCallback?,
                                         onError: ErrorCallback?
    )
    
}
