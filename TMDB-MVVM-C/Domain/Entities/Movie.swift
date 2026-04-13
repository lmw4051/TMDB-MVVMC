//
//  Movie.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import Foundation

struct Movie: Equatable {
  let id: Int
  let title: String
  let overview: String
  let posterPath: String?
  let voteAverage: Double
  let releaseDate: String
}
