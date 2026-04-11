//
//  MockNetworkService.swift
//  TMDB-MVVM-CTests
//
//  Created by David Lee on 4/11/26.
//

import Foundation
@testable import TMDB_MVVM_C

final class MockNetworkService: NetworkServiceProtocol {
  var mockResult: Any?
  var mockError: Error?
  var requestCallCount = 0
  
  func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
    requestCallCount += 1
    
    if let error = mockError {
      throw error
    }
    
    guard let result = mockResult as? T else {
      throw NetworkError.decodingFailed(
        NSError(domain: "Mock", code: -1)
      )
    }
    
    return result
  }
}
