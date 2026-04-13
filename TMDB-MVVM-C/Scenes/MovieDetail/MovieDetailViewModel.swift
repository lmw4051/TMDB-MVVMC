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
  
  // MARK: Private
  private let fetchMovieDetailUseCase: FetchMovieDetailUseCaseProtocol
  private let movieId: Int
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - Init
  init(
    fetchMovieDetailUseCase: FetchMovieDetailUseCaseProtocol,
    movieId: Int
  ) {
    self.fetchMovieDetailUseCase = fetchMovieDetailUseCase
    self.movieId = movieId
  }
  
  // MARK: - Input
  func viewDidLoad() {
    Task { await fetchMovieDetail() }
  }
  
  func retry() {
    Task { await fetchMovieDetail() }
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
}
