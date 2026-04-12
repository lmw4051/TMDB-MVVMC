//
//  MovieRepositoryTests.swift
//  TMDB-MVVM-CTests
//
//  Created by David Lee on 4/12/26.
//

import XCTest
@testable import TMDB_MVVM_C

final class MovieRepositoryTests: XCTestCase {
  var sut: MovieRepository!
  var mockNetworkService: MockNetworkService!
  
  override func setUp() {
    super.setUp()
    mockNetworkService = MockNetworkService()
    sut = MovieRepository(networkService: mockNetworkService)
  }
  
  override func tearDown() {
    sut = nil
    mockNetworkService = nil
    super.tearDown()
  }
  
  @MainActor
  func test_fetchMovies_whenSuccess_shouldReturnMappedMovies() async throws {
    // Arrange
    let dto = MovieListResponseDTO(
      page: 1,
      results: [
        MovieDTO(
          id: 1,
          title: "Inception",
          overview: "Overview",
          posterPath: nil,
          voteAverage: 8.8,
          releaseDate: "2010-07-16"
        )
      ],
      totalPages: 10,
      totalResults: 200
    )
    
    mockNetworkService.mockResult = dto
    
    // Act
    let movies = try await sut.fetchMovies(page: 1)
    
    // Assert
    XCTAssertEqual(movies.count, 1)
    XCTAssertEqual(movies.first?.title, "Inception")
    XCTAssertEqual(movies.first?.voteAverage, 8.8)
  }
  
  func test_fetchMovies_whenNetworkError_shouldThrow() async {
    // Arrange
    mockNetworkService.mockError = NetworkError.invalidResponse
    
    // Act & Assert
    do {
      _ = try await sut.fetchMovies(page: 1)
      XCTFail("Expected error to be thrown")
    } catch {
      XCTAssertTrue(error is NetworkError)
    }
  }
}
