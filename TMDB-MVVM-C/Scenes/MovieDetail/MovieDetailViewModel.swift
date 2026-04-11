//
//  MovieDetailViewModel.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import Foundation
import Combine

final class MovieDetailViewModel {
  // MARK: - Output
  @Published private(set) var movieDetail: MovieDetail?
  @Published private(set) var state: ViewModelState<MovieDetail> = .idle
  
  // MARK: Private
  private let fetchMovieDetailUseCase: FetchMovieDetailUseCaseProtocol
  private let movieId: Int
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - Init
  init(fetchMovieDetailUseCase: FetchMovieDetailUseCaseProtocol, movieId: Int) {
    self.fetchMovieDetailUseCase = fetchMovieDetailUseCase
    self.movieId = movieId
  }
  
  // MARK: - Input
  func viewDidLoad() {
    Task { await fetchMovieDetail() }
  }
  
  // MARK: - Private
  @MainActor
  private func fetchMovieDetail() async {
    state = .loading
    
    do {
      let detail = try await fetchMovieDetailUseCase.execute(id: movieId)
      movieDetail = detail
      state = .success(detail)
    } catch {
      state = .failure(error.localizedDescription)
    }
  }
}
