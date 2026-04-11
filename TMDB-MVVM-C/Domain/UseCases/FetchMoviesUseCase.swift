//
//  FetchMoviesUseCase.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import Foundation

protocol FetchMoviesUseCaseProtocol {
  func execute(page: Int) async throws -> [Movie]
}

final class FetchMoviesUseCase: FetchMoviesUseCaseProtocol {
  private let repository: MovieRepositoryProtocol
  
  init(repository: MovieRepositoryProtocol) {
    self.repository = repository
  }
  
  func execute(page: Int) async throws -> [Movie] {
    try await repository.fetchMovies(page: page)
  }
}
