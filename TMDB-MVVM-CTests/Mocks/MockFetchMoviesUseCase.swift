//
//  MockFetchMoviesUseCase.swift
//  TMDB-MVVM-CTests
//
//  Created by David Lee on 4/12/26.
//

import Foundation
@testable import TMDB_MVVM_C

final class MockFetchMoviesUseCase: FetchMoviesUseCaseProtocol {
  var mockResult: Result<[Movie], Error> = .success([])
  var executeCallCount = 0
  
  func execute(page: Int) async throws -> [Movie] {
    executeCallCount += 1
    return try mockResult.get()
  }
}
