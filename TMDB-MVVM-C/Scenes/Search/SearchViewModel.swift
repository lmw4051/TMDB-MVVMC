//
//  SearchViewModel.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/13/26.
//

import Foundation
import Combine

enum SearchState: Equatable {
  case idle
  case skeletonLoading
  case success([Movie])
  case paginationLoading
  case paginationError(String)
  case empty
  case networkError
  case failure(String)
}

final class SearchViewModel {
  // MARK: - Output
  @Published private(set) var searchState: SearchState = .idle
  @Published private(set) var movies: [Movie] = []
  @Published private(set) var canLoadMore = true
  
  // MARK: - Input（Receive Texts from Search Bar）
  let searchQuery = CurrentValueSubject<String, Never>("")
  
  // MARK: - Private
  private let searchMoviesUseCase: SearchMoviesUseCaseProtocol
  private var currentPage = 1
  private var currentQuery = ""
  private var isFetching = false
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - Init
  init(searchMoviesUseCase: SearchMoviesUseCaseProtocol) {
    self.searchMoviesUseCase = searchMoviesUseCase
    bindSearchQuery()
  }
  
  // MARK: - Debounce Binding
  private func bindSearchQuery() {
    searchQuery
      .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
      .removeDuplicates()
      .sink { [weak self] query in
        guard let self else { return }
        self.handleQueryChange(query)
      }
      .store(in: &cancellables)
  }
  
  private func handleQueryChange(_ query: String) {
    let trimmed = query.trimmingCharacters(in: .whitespaces)
    
    // Empty String -> Back to Idle
    guard !trimmed.isEmpty else {
      movies = []
      canLoadMore = true
      searchState = .idle
      return
    }
    
    // New Text -> Reset to 1st Page
    if trimmed != currentQuery {
      currentQuery = trimmed
      currentPage = 1
      movies = []
      canLoadMore = true
    }
    
    Task { await search(isFirstLoad: true) }
  }
  
  // MARK: - Input Methods
  func loadNextPageIfNeeded(currentIndex: Int) {
    guard currentIndex >= movies.count - 5,
          canLoadMore,
          !isFetching,
          !currentQuery.isEmpty else { return }
    Task { await search(isFirstLoad: false) }
  }
  
  func retryPagination() {
    Task { await search(isFirstLoad: false) }
  }
  
  // MARK: - Private Fetch
  @MainActor
  private func search(isFirstLoad: Bool) async {
    guard !isFetching else { return }
    isFetching = true
    searchState = isFirstLoad ? .skeletonLoading : .paginationLoading
    
    do {
      let newMovies = try await searchMoviesUseCase.execute(
        query: currentQuery,
        page: currentPage
      )
      
      movies.append(contentsOf: newMovies)
      canLoadMore = !newMovies.isEmpty
      
      if movies.isEmpty {
        searchState = .empty
      } else {
        searchState = .success(movies)
        if canLoadMore { currentPage += 1 }
      }
      
    } catch let error as AppError {
      if isFirstLoad {
        searchState = error == .networkUnavailable
        ? .networkError
        : .failure(error.localizedDescription)
      } else {
        searchState = .paginationError(error.localizedDescription)
      }
    } catch {
      searchState = isFirstLoad
      ? .failure(error.localizedDescription)
      : .paginationError(error.localizedDescription)
    }
    
    isFetching = false
  }
}
