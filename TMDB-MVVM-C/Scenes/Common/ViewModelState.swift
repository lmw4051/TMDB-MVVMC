//
//  ViewModelState.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import Foundation

enum ViewModelState<T> {
  case idle
  case loading
  case success(T)
  case failure(String)
}
