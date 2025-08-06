//
//  CombineTestUtils.swift
//  NetworkManager
//
//  Created by Rahul Gangwar on 06/08/25.
//

// CombineTestUtils.swift
import Combine

func awaitPublisher<T: Publisher>(_ publisher: T) async throws -> T.Output where T.Failure: Error {
    try await withCheckedThrowingContinuation { continuation in
        let cancellable = publisher
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        continuation.resume(throwing: error)
                    }
                },
                receiveValue: { value in
                    continuation.resume(returning: value)
                }
            )
        _ = cancellable
    }
}
