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
    let networkService = NetworkService()
    let repository = MovieRepository(networkService: networkService)
    let useCase = FetchMoviesUseCase(repository: repository)
    let viewModel = MovieListViewModel(fetchMoviesUseCase: useCase)
    
    let vc = MovieListViewController(viewModel: viewModel)
    vc.coordinator = self
    navigationController.pushViewController(vc, animated: false)
  }
  
  func showSearch() {
    let searchCoordinator = SearchCoordinator(
      navigationController: navigationController
    )
    
    searchCoordinator.delegate = self
    childCoordinators.append(searchCoordinator)
    searchCoordinator.start()
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
}

// MARK: - SearchCoordinatorDelegate
extension MovieListCoordinator: SearchCoordinatorDelegate {
  func searchCoordinatorDidFinish(_ coordinator: SearchCoordinator) {
    childCoordinators.removeAll { $0 === coordinator }
  }
}

// MARK: - DetailCoordinatorDelegate
extension MovieListCoordinator: DetailCoordinatorDelegate {
  func detailCoordinatorDidFinish(_ coordinator: DetailCoordinator) {
    childCoordinators.removeAll { $0 === coordinator }
  }
}
