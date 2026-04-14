//
//  GetFavoritesUseCase.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/14/26.
//

import Foundation

protocol GetFavoritesUseCaseProtocol {
  func execute() async throws -> [Movie]
}

final class GetFavoritesUseCase: GetFavoritesUseCaseProtocol {
  private let repository: FavoriteRepositoryProtocol
  
  init(repository: FavoriteRepositoryProtocol) {
    self.repository = repository
  }
  
  func execute() async throws -> [Movie] {
    try await repository.getFavorites()
  }
}
