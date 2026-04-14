//
//  CheckFavoriteUseCase.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/14/26.
//

import Foundation

protocol CheckFavoriteUseCaseProtocol {
  func execute(movieId: Int) async throws -> Bool
}

final class CheckFavoriteUseCase: CheckFavoriteUseCaseProtocol {
  private let repository: FavoriteRepositoryProtocol
  
  init(repository: FavoriteRepositoryProtocol) {
    self.repository = repository
  }
  
  func execute(movieId: Int) async throws -> Bool {
    try await repository.checkFavorite(movieId: movieId)
  }
}
