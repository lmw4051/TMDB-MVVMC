//
//  MovieListViewModelTests.swift
//  TMDB-MVVM-CTests
//
//  Created by David Lee on 4/12/26.
//

import XCTest
import Combine
@testable import TMDB_MVVM_C

final class MovieListViewModelTests: XCTestCase {
  var sut: MovieListViewModel!
  var mockUseCase: MockFetchMoviesUseCase!
  var cancellables: Set<AnyCancellable>!
  
  override func setUp() {
    super.setUp()
    mockUseCase = MockFetchMoviesUseCase()
    sut = MovieListViewModel(fetchMoviesUseCase: mockUseCase)
    cancellables = []
  }
  
  override func tearDown() {
    sut = nil
    mockUseCase = nil
    cancellables = nil
    super.tearDown()
  }
  
  @MainActor
  // MARK: - Tests
  func test_viewDidLoad_whenSuccess_shouldUpdateMovies() async {
    // Arrange
    let expectedMovies = MovieStub.makeMovies(count: 5)
    mockUseCase.mockResult = .success(expectedMovies)
    
    // Act
    sut.viewDidLoad()
    
    // Assert
    await Task.yield()
    try? await Task.sleep(nanoseconds: 100_000_000)
    
    XCTAssertEqual(sut.movies.count, 5)
    XCTAssertEqual(sut.movies.first?.title, "Movie 1")
  }
  
  @MainActor
  func test_viewDidLoad_whenFailure_shouldSetErrorState() async {
    // Arrange
    mockUseCase.mockResult = .failure(NetworkError.invalidResponse)
    
    // Act
    sut.viewDidLoad()
    await Task.yield()
    try? await Task.sleep(nanoseconds: 100_000_000)
    
    // Assert
    if case .failure(let message) = sut.listState {
      XCTAssertFalse(message.isEmpty)
    } else {
      XCTFail("Expected failure state")
    }
  }
  
  @MainActor
  func test_loadNextPage_whenAlreadyFetching_shouldNotFetchAgain() async {
    // Arrange
    mockUseCase.mockResult = .success(MovieStub.makeMovies(count: 20))
    sut.viewDidLoad()
    
    // Act
    sut.loadNextPageIfNeeded(currentIndex: 18)
    sut.loadNextPageIfNeeded(currentIndex: 18)
    
    await Task.yield()
    try? await Task.sleep(nanoseconds: 100_000_000)
    
    // Assert
    XCTAssertEqual(mockUseCase.executeCallCount, 1)
  }
  
  @MainActor
  func test_refresh_shouldResetAndFetchFromFirstPage() async {
    // Arrange
    mockUseCase.mockResult = .success(MovieStub.makeMovies(count: 20))
    sut.viewDidLoad()
    await Task.yield()
    
    // Act
    sut.refresh()
    await Task.yield()
    try? await Task.sleep(nanoseconds: 100_000_000)
    
    // Assert
    XCTAssertEqual(sut.movies.count, 20)
    XCTAssertTrue(mockUseCase.executeCallCount >= 2)
  }
}
