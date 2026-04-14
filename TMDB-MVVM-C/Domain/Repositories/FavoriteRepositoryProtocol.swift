//
//  FavoriteRepositoryProtocol.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/14/26.
//

import Foundation

protocol FavoriteRepositoryProtocol {
  func addFavorite(_ movie: Movie) async throws
  func removeFavorite(movieId: Int) async throws
  func getFavorites() async throws -> [Movie]
  func checkFavorite(movieId: Int) async throws -> Bool
}
