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


final class NetworkManagerTests: XCTestCase {
    
    func testRequest_WithMockResponse_ReturnsExpectedData() async throws {
        let url = URL(string: "http://3.147.118.174:5000/api/user/get-profile-details")!
        let token = "eyJhbGciOi..iojpoj"
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
                method: .get,
                headers: headers,
                responseType: MockResponse.self
            )
        )
        
        XCTAssertEqual(result, expected)
    }
    
    func testRequest_RealAPI_ReturnsData() async throws {
        let url = URL(string: "http://3.147.118.174:5000/api/user/get-profile-details")!
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNjg1NDAxOGZlMGZjZGY5ZjgxN2NkOGMwIiwiaWF0IjoxNzU0NDYyNzMwLCJleHAiOjE3NTUxMTA3MzB9.Jxd5mcG7grTBbtqkxLjuTCEHbfsNDuTKI8aBzq9zlK8"
        let headers = [
            "Authorization": "Bearer \(token)"
        ]
        
        let networkManager = NetworkManager()
        
        do {
            let result: MockResponse = try await awaitPublisher(
                networkManager.request(
                    url: url,
                    method: .get,
                    headers: headers,
                    responseType: MockResponse.self
                )
            )
            debugPrint(" SUCCESS:", result)
        } catch {
            let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
            if let httpResponse = response as? HTTPURLResponse {
                print("🔍 Status Code:", httpResponse.statusCode)
            }
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                print("📦 Raw JSON Response:", json)
            } else if let rawString = String(data: data, encoding: .utf8) {
                print("📦 Raw String Response:", rawString)
            }
        }
        
    }
    
}
