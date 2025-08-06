// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Combine

public final class NetworkManager {

    public static let shared = NetworkManager()

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    /// Publisher for Decodable response
    public func request<T: Decodable>(
        url: URL,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        body: Data? = nil,
        timeout: TimeInterval = 30,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError> {

        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = method.rawValue
        request.httpBody = body
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        return session.dataTaskPublisher(for: request)
            .tryMap { result in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                guard (200..<300).contains(httpResponse.statusCode) else {
                    throw NetworkError.statusCode(httpResponse.statusCode)
                }
                return result.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                } else if let decodingError = error as? DecodingError {
                    return NetworkError.decoding(decodingError)
                } else {
                    return NetworkError.url(error)
                }
            }
            .eraseToAnyPublisher()
    }

    /// Publisher for raw data response
    public func requestRaw(
        url: URL,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        body: Data? = nil,
        timeout: TimeInterval = 30
    ) -> AnyPublisher<NetworkRawResponse, NetworkError> {

        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = method.rawValue
        request.httpBody = body
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        return session.dataTaskPublisher(for: request)
            .tryMap { result in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                guard (200..<300).contains(httpResponse.statusCode) else {
                    throw NetworkError.statusCode(httpResponse.statusCode)
                }
                return NetworkRawResponse(data: result.data, response: httpResponse)
            }
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    return NetworkError.url(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
