//
//  Endpoint.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import Foundation

protocol Endpoint {
  var baseURL: String { get }
  var path: String { get }
  var method: HTTPMethod { get }
  var queryItems: [URLQueryItem] { get }
  var headers: [String: String] { get }
}

extension Endpoint {
  func asURLRequest() throws -> URLRequest {
    guard var components = URLComponents(string: baseURL + path) else {
      throw NetworkError.invalidURL
    }
    components.queryItems = queryItems.isEmpty ? nil : queryItems
    
    guard let url = components.url else {
      throw NetworkError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
    return request
  }
}
