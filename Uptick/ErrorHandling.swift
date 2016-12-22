//
//  ErrorHandling.swift
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import Foundation

enum APIManagerError: Error {
    case network(error: Error)
    case apiProvidedError(reason: String)
    case objectSerialization(reason: String)
    case jsonError(reason: String)
}
