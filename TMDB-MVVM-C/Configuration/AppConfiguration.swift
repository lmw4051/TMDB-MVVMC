//
//  AppConfiguration.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import Foundation

enum AppConfiguration {
  static var tmdbAPIKey: String {
    guard let key = Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String,
          !key.isEmpty else {
      fatalError("TMDB_API_KEY not found in Info.plist")
    }
    return key
  }
}
