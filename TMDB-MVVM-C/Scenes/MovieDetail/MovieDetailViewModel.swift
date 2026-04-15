//
//  MovieDetailViewModel.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import Foundation
import Combine

enum DetailState {
  case idle
  case skeletonLoading
  case success(MovieDetail)
  case networkError
  case failure(String)
}

final class MovieDetailViewModel {
  // MARK: - Output
  @Published private(set) var detailState: DetailState = .idle
  @Published private(set) var isFavorite: Bool = false
  
  // MARK: Private
  private let fetchMovieDetailUseCase: FetchMovieDetailUseCaseProtocol
  private let addFavoriteUseCase: AddFavoriteUseCaseProtocol
  private let removeFavoriteUseCase: RemoveFavoriteUseCaseProtocol
  private let checkFavoriteUseCase: CheckFavoriteUseCaseProtocol
  private let movieId: Int
  private var currentMovie: Movie?
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - Init
  init(
    fetchMovieDetailUseCase: FetchMovieDetailUseCaseProtocol,
    addFavoriteUseCase: AddFavoriteUseCaseProtocol,
    removeFavoriteUseCase: RemoveFavoriteUseCaseProtocol,
    checkFavoriteUseCase: CheckFavoriteUseCaseProtocol,
    movieId: Int
  ) {
    self.fetchMovieDetailUseCase = fetchMovieDetailUseCase
    self.addFavoriteUseCase = addFavoriteUseCase
    self.removeFavoriteUseCase = removeFavoriteUseCase
    self.checkFavoriteUseCase = checkFavoriteUseCase
    self.movieId = movieId
  }
  
  // MARK: - Input
  func viewDidLoad() {
    Task {
      await fetchMovieDetail()
      await checkFavoriteStatus()
    }
  }
  
  func retry() {
    Task { await fetchMovieDetail() }
  }
  
  func toggleFavorite() {
    Task { await handleToggleFavorite() }
  }
  
  // MARK: - Private
  @MainActor
  private func fetchMovieDetail() async {
    detailState = .skeletonLoading
    
    do {
      let detail = try await fetchMovieDetailUseCase.execute(id: movieId)
      detailState = .success(detail)
    } catch let error as AppError {
      detailState = error == .networkUnavailable
      ? .networkError
      : .failure(error.localizedDescription)
    } catch {
      detailState = .failure(error.localizedDescription)
    }
  }
  
  @MainActor
  private func checkFavoriteStatus() async {
    do {
      isFavorite = try await checkFavoriteUseCase.execute(movieId: movieId)
    } catch {
      isFavorite = false
    }
  }
  
  @MainActor
  private func handleToggleFavorite() async {
    guard let movie = currentMovie else { return }
    
    do {
      if isFavorite {
        try await removeFavoriteUseCase.execute(movieId: movie.id)
      } else {
        try await addFavoriteUseCase.execute(movie)
      }
      
      isFavorite.toggle()
    } catch {
      print("Toggle favorite failed: \(error)")
    }
  }
}
