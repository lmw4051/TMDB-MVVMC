//
//  MovieDTO.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import Foundation

struct MovieListResponseDTO: Decodable {
  let page: Int
  let results: [MovieDTO]
  let totalPages: Int
  let totalResults: Int
}

struct MovieDTO: Decodable {
  let id: Int
  let title: String
  let overview: String
  let posterPath: String?
  let voteAverage: Double
  let releaseDate: String
}
