//
//  FetchMovieDetailUseCase.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import Foundation

protocol FetchMovieDetailUseCaseProtocol {
  func execute(id: Int) async throws -> MovieDetail
}

final class FetchMovieDetailUseCase: FetchMovieDetailUseCaseProtocol {
  private let repository: MovieRepositoryProtocol
  
  init(repository: MovieRepositoryProtocol) {
    self.repository = repository
  }
  
  func execute(id: Int) async throws -> MovieDetail {
    try await repository.fetchMovieDetail(id: id)
  }
}
