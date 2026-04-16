//
//  FavoritesViewModel.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/15/26.
//

import Foundation
import Combine

enum FavoritesState: Equatable {
  case idle
  case loading
  case success([Movie])
  case empty
  case failure(String)
}

final class FavoritesViewModel {
  // MARK: - Output
  @Published private(set) var favoritesState: FavoritesState = .idle
  @Published private(set) var movies: [Movie] = []
  
  // MARK: - Private
  private let getFavoritesUseCase: GetFavoritesUseCaseProtocol
  private let removeFavoriteUseCase: RemoveFavoriteUseCaseProtocol
  private var cancellables = Set<AnyCancellable>()
  
  init(
    getFavoritesUseCase: GetFavoritesUseCaseProtocol,
    removeFavoriteUseCase: RemoveFavoriteUseCaseProtocol
  ) {
    self.getFavoritesUseCase = getFavoritesUseCase
    self.removeFavoriteUseCase = removeFavoriteUseCase
  }
  
  // MARK: - Input
  func viewWillAppear() {
    Task { await loadFavorites() }
  }
  
  func removeFavorite(at index: Int) {
    let movie = movies[index]
    Task {
      await handleRemoveFavorite(movie: movie, index: index)
    }
  }
  
  // MARK: - Private
  @MainActor
  private func loadFavorites() async {
    favoritesState = .loading
    
    do {
      let favorites = try await getFavoritesUseCase.execute()
      movies = favorites
      favoritesState = favorites.isEmpty ? .empty : .success(favorites)
    } catch {
      favoritesState = .failure(error.localizedDescription)
    }
  }
  
  @MainActor
  private func handleRemoveFavorite(movie: Movie, index: Int) async {
    do {
      try await removeFavoriteUseCase.execute(movieId: movie.id)
      movies.remove(at: index)
      favoritesState = movies.isEmpty ? .empty : .success(movies)
    } catch {
      print("Remove favorite failed: \(error)")
    }
  }
}
