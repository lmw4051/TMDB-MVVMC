//
//  AddFavoriteUseCase.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/14/26.
//

import Foundation

protocol AddFavoriteUseCaseProtocol {
  func execute(_ movie: Movie) async throws
}

final class AddFavoriteUseCase: AddFavoriteUseCaseProtocol {
  private let repository: FavoriteRepositoryProtocol
  
  init(repository: FavoriteRepositoryProtocol) {
    self.repository = repository
  }
  
  func execute(_ movie: Movie) async throws {
    try await repository.addFavorite(movie)
  }
}
