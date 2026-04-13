//
//  MovieRepository.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import Foundation

final class MovieRepository: MovieRepositoryProtocol {
  private let networkService: NetworkServiceProtocol
  
  init(networkService: NetworkServiceProtocol = NetworkService()) {
    self.networkService = networkService
  }
  
  func fetchMovies(page: Int) async throws -> [Movie] {
    let response: MovieListResponseDTO = try await networkService
      .request(TMDBEndpoint.popularMovies(page: page))
    return response.results.map { MovieMapper.toDomain($0) }
  }
  
  func fetchMovieDetail(id: Int) async throws -> MovieDetail {
    let dto: MovieDetailDTO = try await networkService
      .request(TMDBEndpoint.movieDetail(id: id))
    return MovieMapper.toDomain(dto)
  }
  
  func searchMovies(query: String, page: Int) async throws -> [Movie] {
    let response: MovieListResponseDTO = try await networkService.request(TMDBEndpoint.searchMovies(query: query, page: page))
    return response.results.map { MovieMapper.toDomain($0) }
  }
}
