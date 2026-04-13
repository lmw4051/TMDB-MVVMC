//
//  SearchViewModelTests.swift
//  TMDB-MVVM-CTests
//
//  Created by David Lee on 4/13/26.
//

import XCTest
import Combine
@testable import TMDB_MVVM_C

@MainActor
final class SearchViewModelTests: XCTestCase {
  var sut: SearchViewModel!
  var mockUseCase: MockSearchMoviesUseCase!
  var cancellables: Set<AnyCancellable>!
  
  override func setUp() {
    super.setUp()
    mockUseCase = MockSearchMoviesUseCase()
    sut = SearchViewModel(searchMoviesUseCase: mockUseCase)
    cancellables = []
  }
  
  override func tearDown() {
    sut = nil
    mockUseCase = nil
    cancellables = nil
    super.tearDown()
  }
  
  func test_searchQuery_whenEmpty_shouldSetIdleState() {
    // Act
    sut.searchQuery.send("")
    
    // Assert
    XCTAssertEqual(sut.movies.count, 0)
    XCTAssertEqual(sut.searchState, .idle)
  }
  
  func test_searchQuery_whenSuccess_shouldUpdateMovies() async {
    // Arrange
    let expectedMovies = MovieStub.makeMovies(count: 5)
    mockUseCase.mockResult = .success(expectedMovies)
    
    // Act
    sut.searchQuery.send("Inception")
    try? await Task.sleep(nanoseconds: 700_000_000)
    
    // Assert
    XCTAssertEqual(sut.searchState, .success(expectedMovies))
    XCTAssertEqual(sut.movies.count, 5)
  }
  
  func test_searchQuery_whenDuplicate_shouldNotFetchAgain() async {
    // Arrange
    mockUseCase.mockResult = .success(MovieStub.makeMovies(count: 5))
    
    // Act
    sut.searchQuery.send("Inception")
    sut.searchQuery.send("Inception")
    try? await Task.sleep(nanoseconds: 700_000_000)
    
    // Assert
    XCTAssertEqual(mockUseCase.executeCallCount, 1)
  }
  
  func test_searchQuery_whenNetworkError_shouldSetNetworkErrorState() async {
    // Arrange
    mockUseCase.mockResult = .failure(AppError.networkUnavailable)
    
    // Act
    sut.searchQuery.send("Inception")
    try? await Task.sleep(nanoseconds: 700_000_000)
    
    // Assert
    XCTAssertEqual(sut.searchState, .networkError)
  }  
}
