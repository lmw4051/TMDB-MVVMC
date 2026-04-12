//
//  MockMovieRepository.swift
//  TMDB-MVVM-CTests
//
//  Created by David Lee on 4/11/26.
//

import Foundation
@testable import TMDB_MVVM_C

final class MockMovieRepository: MovieRepositoryProtocol {
  var fetchMoviesResult: Result<[Movie], Error> = .success([])
  var fetchMovieDetailResult: Result<MovieDetail, Error> = .success(
    MovieDetail(
      id: 1,
      title: "Mock Movie",
      overview: "Overview",
      posterPath: nil,
      backdropPath: nil,
      voteAverage: 8.0,
      releaseDate: "2024-01-01",
      runtime: 120,
      genres: []
    )
  )
  
  var fetchMoviesCallCount = 0
  
  func fetchMovies(page: Int) async throws -> [Movie] {
    fetchMoviesCallCount += 1
    return try fetchMoviesResult.get()
  }
  
  func fetchMovieDetail(id: Int) async throws -> MovieDetail {
    return try fetchMovieDetailResult.get()
  }
}
