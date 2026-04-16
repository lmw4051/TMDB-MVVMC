//
//  AppCoordinator.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/10/26.
//

import UIKit

final class AppCoordinator: Coordinator {
  var navigationController: UINavigationController = UINavigationController()
  var childCoordinators: [Coordinator] = []
  
  private let tabBarController: UITabBarController
  private let movieListCoordinator: MovieListCoordinator
  private let favoritesCoordinator: FavoritesCoordinator
  
  init(
    tabBarController: UITabBarController,
    movieListCoordinator: MovieListCoordinator,
    favoritesCoordinator: FavoritesCoordinator
  ) {
    self.tabBarController = tabBarController
    self.movieListCoordinator = movieListCoordinator
    self.favoritesCoordinator = favoritesCoordinator
  }
  
  func start() {
    childCoordinators.append(movieListCoordinator)
    childCoordinators.append(favoritesCoordinator)
    movieListCoordinator.start()
    favoritesCoordinator.start()        
  }
}
