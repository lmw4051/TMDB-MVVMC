//
//  MovieStub.swift
//  TMDB-MVVM-CTests
//
//  Created by David Lee on 4/12/26.
//

import Foundation
@testable import TMDB_MVVM_C

enum MovieStub {
  static func makeMovie(
    id: Int = 1,
    title: String = "Inception",
    voteAverage: Double = 8.8
  ) -> Movie {
    Movie(
      id: id,
      title: title,
      overview: "A mind-bending thriller",
      posterPath: "/poster.jpg",
      voteAverage: voteAverage,
      releaseDate: "2010-07-16"
    )
  }
  
  static func makeMovies(count: Int) -> [Movie] {
    (1...count).map { makeMovie(id: $0, title: "Movie \($0)") }
  }
}

extension MovieStub {
  static func makeDTOs(count: Int, startId: Int = 1) -> [MovieDTO] {
    (startId ..< startId + count).map {
      MovieDTO(
        id: $0,
        title: "Movie \($0)",
        overview: "Overview \($0)",
        posterPath: nil,
        voteAverage: 7.0,
        releaseDate: "2024-01-01"
      )
    }
  }
}
