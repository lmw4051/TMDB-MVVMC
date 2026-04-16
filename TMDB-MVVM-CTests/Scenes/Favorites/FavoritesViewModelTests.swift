//
//  FavoritesViewModelTests.swift
//  TMDB-MVVM-CTests
//
//  Created by David Lee on 4/16/26.
//

import XCTest
import Combine
@testable import TMDB_MVVM_C

@MainActor
final class FavoritesViewModelTests: XCTestCase {
  var sut: FavoritesViewModel!
  var mockRepository: MockFavoriteRepository!
  var cancellables: Set<AnyCancellable>!
  
  override func setUp() {
    super.setUp()
    mockRepository = MockFavoriteRepository()
    sut = FavoritesViewModel(
      getFavoritesUseCase: GetFavoritesUseCase(repository: mockRepository),
      removeFavoriteUseCase: RemoveFavoriteUseCase(repository: mockRepository)
    )
    
    cancellables = []
  }
  
  override func tearDown() {
    sut = nil
    mockRepository = nil
    cancellables = nil
    super.tearDown()
  }
  
  func test_viewWillAppear_whenFavoritesExist_shouldSetSuccessState() async {
    // Arrange
    mockRepository.favorites = MovieStub.makeMovies(count: 3)
    
    // Act
    sut.viewWillAppear()
    try? await Task.sleep(nanoseconds: 100_000_000)
    
    // Assert
    XCTAssertEqual(sut.favoritesState, .success(mockRepository.favorites))
    XCTAssertEqual(sut.movies.count, 3)
  }
  
  func test_viewWillAppear_whenNoFavorites_shouldSetEmptyState() async {
    // Arrange
    mockRepository.favorites = []
    
    // Act
    sut.viewWillAppear()
    try? await Task.sleep(nanoseconds: 100_000_000)
    
    // Assert
    XCTAssertEqual(sut.favoritesState, .empty)
  }
  
  func test_removeFavorite_shouldRemoveFromList() async {
    // Arrange
    mockRepository.favorites = MovieStub.makeMovies(count: 3)
    sut.viewWillAppear()
    try? await Task.sleep(nanoseconds: 100_000_000)
    
    // Act
    sut.removeFavorite(at: 0)
    try? await Task.sleep(nanoseconds: 100_000_000)
    
    // Assert
    XCTAssertEqual(sut.movies.count, 2)
    XCTAssertEqual(mockRepository.removeCallCount, 1)
  }
}
