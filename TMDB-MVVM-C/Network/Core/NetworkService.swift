//
//  NetworkService.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import Foundation

enum NetworkError: Error, LocalizedError {
  case invalidURL
  case invalidResponse
  case statusCode(Int)
  case decodingFailed(Error)
  case unknown(Error)
  
  var errorDescription: String? {
    switch self {
    case .invalidURL:         return "Invalid URL"
    case .invalidResponse:    return "Invalid response"
    case .statusCode(let c):  return "Status code: \(c)"
    case .decodingFailed:     return "Decoding failed"
    case .unknown(let e):     return e.localizedDescription
    }
  }
}

protocol NetworkServiceProtocol {
  func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class NetworkService: NetworkServiceProtocol {
  private let session: URLSession
  private let decoder: JSONDecoder
  
  init(session: URLSession = .shared) {
    self.session = session
    self.decoder = JSONDecoder()
    self.decoder.keyDecodingStrategy = .convertFromSnakeCase
  }
  
  func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
    let request = try endpoint.asURLRequest()
    
    let (data, response) = try await session.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      throw NetworkError.invalidResponse
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
      throw NetworkError.statusCode(httpResponse.statusCode)
    }
    
    do {
      return try decoder.decode(T.self, from: data)
    } catch {
      throw NetworkError.decodingFailed(error)
    }
  }
}
