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
  private let retryHandler: RetryHandler
  
  init(
    session: URLSession = .shared,
    retryHandler: RetryHandler = RetryHandler()
  ) {
    self.session = session
    self.decoder = JSONDecoder()
    self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    self.retryHandler = retryHandler
  }
  
  func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
    try await retryHandler.execute {
      let request = try endpoint.asURLRequest()
      
      let (data, response): (Data, URLResponse)

      do {
        (data, response) = try await session.data(for: request)
      } catch let urlError as URLError {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost:
          throw AppError.networkUnavailable
        case .timedOut:
          throw AppError.timeout
        default:
          throw AppError.unknown(urlError)
        }
      }
      
      guard let httpResponse = response as? HTTPURLResponse else {
        throw AppError.unknown(NetworkError.invalidResponse)
      }
      
      guard (200...299).contains(httpResponse.statusCode) else {
        throw AppError.from(.statusCode(httpResponse.statusCode))
      }
      
      do {
        return try decoder.decode(T.self, from: data)
      } catch {
        throw AppError.decodingFailed
      }
    }
  }
}
