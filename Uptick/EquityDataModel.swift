//
//  EquityDataModel.swift
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import Foundation
import SwiftSpinner

protocol EquityViewControllerModelDelegate: class {
    func didReceiveDataUpdate(data: [Equity])
    func didFailDataUpdateWithError(error: Error)
}

class EquityDataModel: NSObject {
    weak var delegate: EquityViewControllerModelDelegate?
    
    func requestData() {
        var equityTickers: Array<String> = []
        let symbols = UserDefaultsManagement.getTickers()
        for symbol in symbols {
            equityTickers.append(symbol)
        }

        SwiftSpinner.show(delay: 2.0, title: "Fetching Stocks")
        EquityNetworkManager.requestEquityData(symbols: equityTickers, onSuccess: { data in
            self.setDataWithResponse(response: data)
            SwiftSpinner.hide()
        }, onError: { error in
            self.handleError(error: error)
            SwiftSpinner.hide()
        })
    }
    
    private func setDataWithResponse(response: [Equity]) {
        var data = [Equity]()
        
        for object in response {
            data.append(object)
        }
        delegate?.didReceiveDataUpdate(data: data)
    }
    
    private func handleError(error: Error) {
        delegate?.didFailDataUpdateWithError(error: error)
    }
}
