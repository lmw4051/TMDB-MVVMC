//
//  AppError.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/12/26.
//

import Foundation

enum AppError: Error, LocalizedError {
  case networkUnavailable // No network connection
  case timeout // Request timeout
  case serverError(Int) // Server error (5xx)
  case unauthorized // Invalid API Key (401)
  case notFound // Resource not found (404)
  case decodingFailed // Decoding failed
  case unknown(Error) // Other unknown error
  
  var errorDescription: String? {
    switch self {
    case .networkUnavailable: return "Network connection failed, please check your network status."
    case .timeout:            return "Connection timed out, please try again later."
    case .serverError(let c): return "Server error (\(c)), please try again later."
    case .unauthorized:       return "API authentication failed, please check your API Key."
    case .notFound:           return "Data not found."
    case .decodingFailed:     return "Data decoding failed."
    case .unknown(let e):     return e.localizedDescription
    }
  }
  
  // Is this error retryable?
  var isRetryable: Bool {
    switch self {
    case .networkUnavailable, .timeout, .serverError: return true
    case .unauthorized, .notFound, .decodingFailed, .unknown: return false
    }
  }
  
  // Convert from NetworkError
  static func from(_ networkError: NetworkError) -> AppError {
    switch networkError {
    case .statusCode(401):
      return .unauthorized
    case .statusCode(404):
      return .notFound
    case .statusCode(let c) where c >= 500:
      return .serverError(c)
    case .decodingFailed:
      return .decodingFailed
    case .invalidURL, .invalidResponse:
      return .unknown(networkError)
    default:
      return .unknown(networkError)
    }
  }
}
