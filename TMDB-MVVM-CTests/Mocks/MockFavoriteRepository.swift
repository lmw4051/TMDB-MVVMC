//
//  MockFavoriteRepository.swift
//  TMDB-MVVM-CTests
//
//  Created by David Lee on 4/16/26.
//

import Foundation
@testable import TMDB_MVVM_C

final class MockFavoriteRepository: FavoriteRepositoryProtocol {
  var favorites: [Movie] = []
  var addCallCount = 0
  var removeCallCount = 0
  
  func addFavorite(_ movie: Movie) async throws {
    addCallCount += 1
    favorites.append(movie)
  }
  
  func removeFavorite(movieId: Int) async throws {
    removeCallCount += 1
    favorites.removeAll { $0.id == movieId }
  }
  
  func getFavorites() async throws -> [Movie] {
    favorites
  }
  
  func checkFavorite(movieId: Int) async throws -> Bool {
    favorites.contains { $0.id == movieId }
  }
}
