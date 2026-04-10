//
//  MovieListCoordinator.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/10/26.
//

import UIKit

final class MovieListCoordinator: Coordinator {
  var navigationController: UINavigationController
  var childCoordinators: [Coordinator] = []
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    
  }
}
