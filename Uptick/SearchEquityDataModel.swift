//
//  SearchEquityDataModel.swift
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import Foundation
import SwiftSpinner

protocol SearchEquityViewControllerModelDelegate: class {
    func didReceiveSearchData(data: [EquitySearch])
    func didFailSearchDataWithError(error: Error)
}

class SearchEquityDataModel: NSObject {
    weak var delegate: SearchEquityViewControllerModelDelegate?
    
    func requestData(searchText: String) {
        SwiftSpinner.show(delay: 2.0, title: "Fetching Search Results")
        EquityNetworkManager.searchEquity(searchText: searchText, onSuccess: { data in
            self.setDataWithResponse(response: data)
            SwiftSpinner.hide()
        }, onError: { error in
            self.handleError(error: error)
            SwiftSpinner.hide()
        })
    }
    
    private func setDataWithResponse(response: [EquitySearch]) {
        var data = [EquitySearch]()
        
        for object in response {
            data.append(object)
        }
        delegate?.didReceiveSearchData(data: data)
    }
    
    private func handleError(error: Error) {
       delegate?.didFailSearchDataWithError(error: error)
    }
}
