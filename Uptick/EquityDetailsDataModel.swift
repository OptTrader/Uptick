//
//  EquityDetailsDataModel.swift
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import Foundation
import SwiftSpinner

protocol EquityDetailsViewControllerModelDelegate: class {
    func didReceiveDataUpdate(data: EquityDetails)
    func didFailDataUpdateWithError(error: Error)
}

class EquityDetailsDataModel: NSObject {
    weak var delegate: EquityDetailsViewControllerModelDelegate?
    
    func requestData(stockSymbol: String) {
        SwiftSpinner.show(delay: 2.0, title: "Fetching Data")
        EquityNetworkManager.requestEquityDetailsData(symbol: stockSymbol, onSuccess: { data in
            self.setDataWithResponse(response: data)
            SwiftSpinner.hide()
        }, onError: { error in
            self.handleError(error: error)
            SwiftSpinner.hide()
        })
    }
    
    private func setDataWithResponse(response: EquityDetails) {
        let data: EquityDetails = response
        delegate?.didReceiveDataUpdate(data: data)
    }
    
    private func handleError(error: Error) {
        delegate?.didFailDataUpdateWithError(error: error)
    }
}
