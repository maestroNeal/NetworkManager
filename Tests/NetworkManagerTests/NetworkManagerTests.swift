import Testing
import Foundation
import Combine
import XCTest
@testable import NetworkManager

struct MockResponse: Codable, Equatable {
    let message: String
    let status_code: Int
    let error: Bool
}

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    let url = URL(string: "hhttp://3.147.118.174:5000/api/user/get-profile-details")!
    let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjg1NDAxOGZlMGZjZGY5ZjgxN2NkOGMwIiwiaWF0IjoxNzU0NDYyNzMwLCJleHAiOjE3NTUxMTA3MzB9.Jxd5mcG7grTBbtqkxLjuTCEHbfsNDuTKI8aBzq9zlK8"
    let headers = [
        "Authorization": "Bearer \(token)"
    ]
    let expected = MockResponse(message: "User profile fetched successfully", status_code: 200, error: false)
    let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: headers)!
    let data = try JSONEncoder().encode(expected)
    MockURLProtocol.stubData = data
    MockURLProtocol.stubResponse = response
    MockURLProtocol.stubError = nil
    
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let session = URLSession(configuration: config)
    let networkManager = NetworkManager(session: session)
    let result: MockResponse = try await awaitPublisher(
        networkManager.request(url: url, responseType: MockResponse.self)
    )
}

final class NetworkManagerTests: XCTestCase {
    
    func testRequest_WithMockResponse_ReturnsExpectedData() async throws {
        let url = URL(string: "http://3.147.118.174:5000/api/user/get-profile-details")!
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjg1NDAxOGZlMGZjZGY5ZjgxN2NkOGMwIiwiaWF0IjoxNzU0NDYyNzMwLCJleHAiOjE3NTUxMTA3MzB9.Jxd5mcG7grTBbtqkxLjuTCEHbfsNDuTKI8aBzq9zlK8"
        let headers = [
            "Authorization": "Bearer \(token)"
        ]

        let expected = MockResponse(
            message: "User profile fetched successfully",
            status_code: 200,
            error: false
        )

        let data = try JSONEncoder().encode(expected)
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        MockURLProtocol.stubData = data
        MockURLProtocol.stubResponse = response
        MockURLProtocol.stubError = nil

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)

        let networkManager = NetworkManager(session: session)

        let result: MockResponse = try await awaitPublisher(
            networkManager.request(
                url: url,
                headers: headers,
                responseType: MockResponse.self
            )
        )

        XCTAssertEqual(result, expected)
    }

}
