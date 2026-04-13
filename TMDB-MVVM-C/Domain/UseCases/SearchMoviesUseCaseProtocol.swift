//
//  SearchMoviesUseCaseProtocol.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/13/26.
//

import Foundation

protocol SearchMoviesUseCaseProtocol {
  func execute(query: String, page: Int) async throws -> [Movie]
}

final class SearchMoviesUseCase: SearchMoviesUseCaseProtocol {
  private let repository: MovieRepositoryProtocol
  
  init(repository: MovieRepositoryProtocol) {
    self.repository = repository
  }
  
  func execute(query: String, page: Int) async throws -> [Movie] {
    // if query is empty, then just return empty array
    guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
      return []
    }
    return try await repository.searchMovies(query: query, page: page)
  }
}
