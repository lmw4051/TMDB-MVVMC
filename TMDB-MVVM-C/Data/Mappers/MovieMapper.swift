//
//  MovieMapper.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import Foundation

enum MovieMapper {
  static func toDomain(_ dto: MovieDTO) -> Movie {
    Movie(
      id: dto.id,
      title: dto.title,
      overview: dto.overview,
      posterPath: dto.posterPath,
      voteAverage: dto.voteAverage,
      releaseDate: dto.releaseDate
    )
  }
  
  static func toDomain(_ dto: MovieDetailDTO) -> MovieDetail {
    MovieDetail(
      id: dto.id,
      title: dto.title,
      overview: dto.overview,
      posterPath: dto.posterPath,
      backdropPath: dto.backdropPath,
      voteAverage: dto.voteAverage,
      releaseDate: dto.releaseDate,
      runtime: dto.runtime,
      genres: dto.genres.map { Genre(id: $0.id, name: $0.name) }
    )
  }
}
