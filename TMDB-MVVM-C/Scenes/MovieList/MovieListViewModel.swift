//
//  MovieListViewModel.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import Foundation
import Combine

enum ListState {
  case idle
  case skeletonLoading
  case paginationLoading
  case success
  case empty
  case networkError
  case paginationError(String)
  case failure(String)
}

final class MovieListViewModel {
  // MARK: - Output
  @Published private(set) var movies: [Movie] = []
  @Published private(set) var listState: ListState = .idle
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
    Task { await fetchMovies(isFirstLoad: true) }
  }
  
  func loadNextPageIfNeeded(currentIndex: Int) {
    guard currentIndex >= movies.count - 5,
          canLoadMore,
          !isFetching else {
      return
    }
    
    Task { await fetchMovies(isFirstLoad: true) }
  }
  
  func refresh() {
    currentPage = 1
    movies = []
    canLoadMore = true
    Task { await fetchMovies(isFirstLoad: true) }
  }
  
  func retryPagination() {
    Task { await fetchMovies(isFirstLoad: false) }
  }
  
  // MARK: - Private
  @MainActor
  private func fetchMovies(isFirstLoad: Bool) async {
    guard !isFetching else { return }
    isFetching = true
    listState = isFirstLoad ? .skeletonLoading : .paginationLoading
    
    do {
      let newMovies = try await fetchMoviesUseCase.execute(page: currentPage)
      
      movies.append(contentsOf: newMovies)
      canLoadMore = !newMovies.isEmpty
      
      if movies.isEmpty {
        listState = .empty
      } else {
        listState = .success
        if canLoadMore { currentPage += 1 }
      }
    } catch let error as AppError {
      if isFirstLoad {
        listState = error == .networkUnavailable
        ? .networkError
        : .failure(error.localizedDescription)
      } else {
        listState = .paginationError(error.localizedDescription)
      }
    } catch {
      listState = isFirstLoad
      ? .failure(error.localizedDescription)
      : .paginationError(error.localizedDescription)
    }
    
    isFetching = false
  }
}

extension AppError: Equatable {
  static func == (lhs: AppError, rhs: AppError) -> Bool {
    lhs.errorDescription == rhs.errorDescription
  }
}
