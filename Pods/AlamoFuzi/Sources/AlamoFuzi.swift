// 
//  AlamoFuzi.swift
//
//  Copyright (c) 2015-2016 Jonas Zaugg
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import Alamofire
import Fuzi

// MARK: - Fuzi HTML

extension DataRequest {
    
    /// Creates a response serializer that returns a result HTML document type initialized from the response data
    ///
    /// - returns: An HTML document response serializer
    static func htmlResponseSerializer() -> DataResponseSerializer<HTMLDocument> {
        return DataResponseSerializer { request, response, data, error in
            // Pass through any underlying URLSession error to the .network case.
            guard error == nil else { return .failure(AlamoFuziError.network(error: error!)) }
            
            // Use Alamofire's existing data serializer to extract the data, passing the error as nil, as it has
            // already been handled.
            let result = Request.serializeResponseData(response: response, data: data, error: nil)
            
            guard case let .success(validData) = result else {
                return .failure(AlamoFuziError.dataSerialization(error: result.error! as! AFError))
            }
            
            do {
                let html = try HTMLDocument(data: validData)
                return .success(html)
            } catch {
                return .failure(AlamoFuziError.htmlSerialization(error: error as! XMLError))
            }
        }
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseHTML(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<HTMLDocument>) -> Void)
        -> Self
    {
        return response(
            queue: queue,
            responseSerializer: DataRequest.htmlResponseSerializer(),
            completionHandler: completionHandler
        )
    }
}

// MARK: - Fuzi XML

extension DataRequest {
    
    /// Creates a response serializer that returns a result XML document type initialized from the response data
    ///
    /// - returns: An XML document response serializer
    static func xmlResponseSerializer() -> DataResponseSerializer<Fuzi.XMLDocument> {
        return DataResponseSerializer { request, response, data, error in
            // Pass through any underlying URLSession error to the .network case.
            guard error == nil else { return .failure(AlamoFuziError.network(error: error!)) }
            
            // Use Alamofire's existing data serializer to extract the data, passing the error as nil, as it has
            // already been handled.
            let result = Request.serializeResponseData(response: response, data: data, error: nil)
            
            guard case let .success(validData) = result else {
                return .failure(AlamoFuziError.dataSerialization(error: result.error! as! AFError))
            }
            
            do {
                let xml = try XMLDocument(data: validData)
                return .success(xml)
            } catch {
                return .failure(AlamoFuziError.xmlSerialization(error: error as! XMLError))
            }
        }
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter completionHandler: A closure to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    public func responseXML(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<Fuzi.XMLDocument>) -> Void)
        -> Self
    {
        return response(
            queue: queue,
            responseSerializer: DataRequest.xmlResponseSerializer(),
            completionHandler: completionHandler
        )
    }
}


/// `AlamoFuziError` is the error type returned by AlamoFuzi. It encompasses a few different types of errors.
///
/// - network:            Captures any underlying Error from the URLSession API
/// - dataSerialization:  Captures any Error occuring during the serialization of the response Data
/// - xmlSerialization:   Captures any Error happening during the serialization of the response XML
/// - htmlSerialization:  Captures any Error happening during the serialization of the response HTML
enum AlamoFuziError: Error {
    case network(error: Error)
    case dataSerialization(error: Error)
    case xmlSerialization(error: Error)
    case htmlSerialization(error: Error)
}
