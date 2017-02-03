//
//  SearchDataModel.swift
//  Uptick
//
//  Created by Chris Kong on 1/24/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import Foundation
import SwiftSpinner

protocol SearchViewControllerModelDelegate: class {
    func didReceiveSearchData(data: [Search])
    func didFailSearchDataWithError(error: Error)
}

class SearchDataModel: NSObject {
    weak var delegate: SearchViewControllerModelDelegate?
    
    func requestData(searchText: String) {
        SwiftSpinner.show(delay: 2.0, title: "Fetching Search Results")
        
        SearchNetworkManager.searchAsset(searchText: searchText, onSuccess: { data in
            self.setDataWithResponse(response: data)
            SwiftSpinner.hide()
        }, onError: { error in
            self.handleError(error: error)
            SwiftSpinner.hide()
        })
    }
    
    private func setDataWithResponse(response: [Search]) {
        var data = [Search]()
        
        for object in response {
            data.append(object)
        }
        delegate?.didReceiveSearchData(data: data)
    }
    
    private func handleError(error: Error) {
        delegate?.didFailSearchDataWithError(error: error)
    }
}
