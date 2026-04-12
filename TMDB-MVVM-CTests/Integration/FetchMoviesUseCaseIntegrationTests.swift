//
//  FetchMoviesUseCaseIntegrationTests.swift
//  TMDB-MVVM-CTests
//
//  Created by David Lee on 4/12/26.
//

import XCTest
@testable import TMDB_MVVM_C

final class FetchMoviesUseCaseIntegrationTests: XCTestCase {
  var sut: FetchMoviesUseCase!
  var mockNetworkService: MockNetworkService!
  var repository: MovieRepository!
  
  @MainActor
  override func setUp() {
    super.setUp()
    mockNetworkService = MockNetworkService()
    repository = MovieRepository(networkService: mockNetworkService)
    sut = FetchMoviesUseCase(repository: repository)
  }
  
  override func tearDown() {
    sut = nil
    repository = nil
    mockNetworkService = nil
    super.tearDown()
  }
  
  @MainActor
  func test_execute_whenRepositoryReturnsMovies_shouldPassThroughToUseCase() async throws {
    // Arrange
    let dto = MovieListResponseDTO(
      page: 1,
      results: [
        MovieDTO(id: 1,
                 title: "Inception",
                 overview: "Overview",
                 posterPath: nil,
                 voteAverage: 8.8,
                 releaseDate: "2010-07-16"),
        MovieDTO(id: 2,
                 title: "Interstellar",
                 overview: "Overview",
                 posterPath: nil,
                 voteAverage: 8.6,
                 releaseDate: "2014-11-07")
      ],
      totalPages: 10,
      totalResults: 200
    )
    
    mockNetworkService.mockResult = dto
    
    let movies = try await sut.execute(page: 1)
    
    XCTAssertEqual(movies.count, 2)
    XCTAssertEqual(movies[0].title, "Inception")
    XCTAssertEqual(movies[1].title, "Inception")
    XCTAssertEqual(mockNetworkService.requestCallCount, 1)
  }
  
  func test_execute_whenNetworkFails_shouldPropagateError() async {
    // Arrange
    mockNetworkService.mockError = NetworkError.statusCode(401)
    
    // Act & Assert
    do {
      _ = try await sut.execute(page: 1)
      XCTFail("Expected error to be thrown")
    } catch let error as NetworkError {
      if case .statusCode(let code) = error {
        XCTAssertEqual(code, 401)
      } else {
        XCTFail("Expected statusCode error")
      }
    } catch {
      XCTFail("Unexpected error type")
    }
  }
  
  @MainActor
  func test_execute_whenMultiplePages_shouldAccumulateCorrectly() async throws {
    // Arrange
    let firstPageDTO = MovieListResponseDTO(
      page: 1,
      results: MovieStub.makeDTOs(count: 20),
      totalPages: 5,
      totalResults: 100
    )
    mockNetworkService.mockResult = firstPageDTO
    
    // Act
    let firstPage = try await sut.execute(page: 1)
    
    // Simulate 2nd page
    let secondPageDTO = MovieListResponseDTO(
      page: 2,
      results: MovieStub.makeDTOs(
        count: 20,
        startId: 21
      ),
      totalPages: 5,
      totalResults: 100
    )
    
    mockNetworkService.mockResult = secondPageDTO
    let secondPage = try await sut.execute(page: 2)
    
    // Assert
    XCTAssertEqual(firstPage.count, 20)
    XCTAssertEqual(secondPage.count, 20)
    XCTAssertNotEqual(firstPage.first?.id, secondPage.first?.id)
    XCTAssertEqual(mockNetworkService.requestCallCount, 2)
  }
}
