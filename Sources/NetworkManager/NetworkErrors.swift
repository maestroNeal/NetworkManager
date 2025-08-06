//
//  NetworkErrors.swift
//  NetworkManager
//
//  Created by Rahul Gangwar on 06/08/25.
//

import Foundation


public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public enum NetworkError: Error {
    case url(Error)
    case decoding(Error)
    case invalidResponse
    case statusCode(Int)
}

public struct NetworkRawResponse {
    public let data: Data
    public let response: HTTPURLResponse
}
