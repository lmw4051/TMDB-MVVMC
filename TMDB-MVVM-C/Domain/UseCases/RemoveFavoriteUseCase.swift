//
//  RemoveFavoriteUseCase.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/14/26.
//

import Foundation

protocol RemoveFavoriteUseCaseProtocol {
  func execute(movieId: Int) async throws
}

final class RemoveFavoriteUseCase: RemoveFavoriteUseCaseProtocol {
  private let repository: FavoriteRepositoryProtocol
  
  init(repository: FavoriteRepositoryProtocol) {
    self.repository = repository
  }
  
  func execute(movieId: Int) async throws {
    try await repository.removeFavorite(movieId: movieId)
  }
}
