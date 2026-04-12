//
//  RetryHandler.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/12/26.
//

import Foundation

struct RetryHandler {
  let maxAttempts: Int
  let delay: TimeInterval
  let multiplier: Double
  
  init(
    maxAttempts: Int = 3,
    delay: TimeInterval = 1.0,
    multiplier: Double = 2.0
  ) {
    self.maxAttempts = maxAttempts
    self.delay = delay
    self.multiplier = multiplier
  }
  
  func execute<T>(_ operation: () async throws -> T) async throws -> T {
    var currentDelay = delay
    var lastError: Error?
    
    for attemp in 1...maxAttempts {
      do {
        return try await operation()
      } catch let error as AppError {
        lastError = error
        guard error.isRetryable, attemp < maxAttempts else {
          throw error
        }
        
        // Exponential backoff: 1s -> 2s -> 4s
        try await Task.sleep(nanoseconds: UInt64(currentDelay * 1_000_000_000))
        currentDelay *= multiplier
      } catch {
        throw error
      }
    }
    
    throw lastError ?? AppError.unknown(NSError(domain: "Retry", code: -1))
  }
}
