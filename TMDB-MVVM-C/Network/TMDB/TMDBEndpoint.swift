//
//  TMDBEndpoint.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import Foundation

enum TMDBEndpoint: Endpoint {
  case popularMovies(page: Int)
  case movieDetail(id: Int)
  case searchMovies(query: String, page: Int)
  
  var baseURL: String { "https://api.themoviedb.org/3" }
  
  var path: String {
    switch self {
    case .popularMovies:       
      return "/movie/popular"
    case .movieDetail(let id): 
      return "/movie/\(id)"
    case .searchMovies:
      return "/search/movie"
    }
  }
  
  var method: HTTPMethod { .get }
  
  var queryItems: [URLQueryItem] {
    var items = [
      URLQueryItem(
        name: "api_key",
        value: AppConfiguration.tmdbAPIKey
      )
    ]
    
    switch self {
    case .popularMovies(let page):
      items.append(
        URLQueryItem(
          name: "page",
          value: "\(page)"
        )
      )
      
    case .movieDetail:
      break
      
    case .searchMovies(let query, let page):
      items.append(
        URLQueryItem(
          name: "query",
          value: query
        )
      )
      
      items.append(
        URLQueryItem(
          name: "page",
          value: "\(page)"
        )
      )
    }
    
    return items
  }
  
  var headers: [String: String] { [:] }
}
