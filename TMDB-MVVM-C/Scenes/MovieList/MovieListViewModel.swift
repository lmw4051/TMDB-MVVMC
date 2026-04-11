//
//  MovieListViewModel.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import Foundation
import Combine

final class MovieListViewModel {
  // MARK: - Output
  @Published private(set) var movies: [Movie] = []
  @Published private(set) var state: ViewModelState<[Movie]> = .idle
  @Published private(set) var canLoadMore: Bool = true
  
  // MARK: - Private
  private let fetchMoviesUseCase: FetchMoviesUseCaseProtocol
  private var currentPage = 1
  private var isFetching = false
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: Init
  init(fetchMoviesUseCase: FetchMoviesUseCaseProtocol) {
    self.fetchMoviesUseCase = fetchMoviesUseCase
  }
  
  // MARK: - Input
  func viewDidLoad() {
    Task { await fetchMovies() }
  }
  
  func loadNextPageIfNeeded(currentIndex: Int) {
    guard currentIndex >= movies.count - 5,
          canLoadMore,
          !isFetching else {
      return
    }
    
    Task { await fetchMovies() }
  }
  
  func refresh() {
    currentPage = 1
    movies = []
    canLoadMore = true
    Task { await fetchMovies() }
  }
  
  // MARK: - Private
  @MainActor
  private func fetchMovies() async {
    guard !isFetching else { return }
    isFetching = true
    state = .loading
    
    do {
      let newMovies = try await fetchMoviesUseCase.execute(page: currentPage)
      movies.append(contentsOf: newMovies)
      state = .success(movies)
      currentPage += 1
      canLoadMore = !newMovies.isEmpty
    } catch {
      state = .failure(error.localizedDescription)
    }
    
    isFetching = false
  }
}
