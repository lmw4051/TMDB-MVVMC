//
//  FavoritesCoordinator.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/16/26.
//

import UIKit

protocol FavoritesCoordinatorDelegate: AnyObject {
  func favoritesCoordinatorDidFinish(_ coordinator: FavoritesCoordinator)
}

final class FavoritesCoordinator: Coordinator {
  var navigationController: UINavigationController
  var childCoordinators: [Coordinator] = []
  weak var delegate: FavoritesCoordinatorDelegate?
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let repository = FavoriteRepository()
    let getFavoritesUseCase = GetFavoritesUseCase(repository: repository)
    let removeFavoriteUseCase = RemoveFavoriteUseCase(repository: repository)
    let viewModel = FavoritesViewModel(
      getFavoritesUseCase: getFavoritesUseCase,
      removeFavoriteUseCase: removeFavoriteUseCase
    )
    
    let vc = FavoritesViewController(viewModel: viewModel)
    vc.coordinator = self
    navigationController.pushViewController(vc, animated: true)
  }
  
  func showDetail(movieId: Int) {
    let detailCoordinator = DetailCoordinator(
      navigationController: navigationController,
      movieId: movieId
    )
    
    detailCoordinator.delegate = self
    childCoordinators.append(detailCoordinator)
    detailCoordinator.start()
  }
  
  func didFinish() {
    delegate?.favoritesCoordinatorDidFinish(self)
  }
}

// MARK: - DetailCoordinatorDelegate
extension FavoritesCoordinator: DetailCoordinatorDelegate {
  func detailCoordinatorDidFinish(_ coordinator: DetailCoordinator) {
    childCoordinators.removeAll { $0 === coordinator }
  }
}
