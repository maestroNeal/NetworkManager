//
//  MockURLProtocol.swift
//  NetworkManager
//
//  Created by Rahul Gangwar on 06/08/25.
//

import Foundation
import Combine

final class MockURLProtocol : URLProtocol {
    
    static var stubData: Data?
    static var stubResponse: HTTPURLResponse?
    static var stubError: Error?
    
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
    override func startLoading() {
        if let error = Self.stubError {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = Self.stubResponse {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = Self.stubData {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}

}
