//
//  MovieDetail.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import Foundation

struct MovieDetail {
  let id: Int
  let title: String
  let overview: String
  let posterPath: String?
  let backdropPath: String?
  let voteAverage: Double
  let releaseDate: String
  let runtime: Int?
  let genres: [Genre]
}

struct Genre {
  let id: Int
  let name: String
}
