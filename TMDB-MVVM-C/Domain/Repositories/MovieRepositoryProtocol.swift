//
//  MovieRepositoryProtocol.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import Foundation

protocol MovieRepositoryProtocol {
  func fetchMovies(page: Int) async throws -> [Movie]
  func fetchMovieDetail(id: Int) async throws -> MovieDetail
  func searchMovies(query: String, page: Int) async throws -> [Movie]
}
