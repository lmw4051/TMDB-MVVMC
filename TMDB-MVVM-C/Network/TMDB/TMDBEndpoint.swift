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
  
  var baseURL: String { "https://api.themoviedb.org/3" }
  
  var path: String {
    switch self {
    case .popularMovies:       
      return "/movie/popular"
    case .movieDetail(let id): 
      return "/movie/\(id)"
    }
  }
  
  var method: HTTPMethod { .get }
  
  var queryItems: [URLQueryItem] {
    var items = [URLQueryItem(name: "api_key",
                              value: AppConfiguration.tmdbAPIKey)]
    switch self {
    case .popularMovies(let page):
      items.append(URLQueryItem(name: "page", value: "\(page)"))
    case .movieDetail:
      break
    }
    return items
  }
  
  var headers: [String: String] { [:] }
}
