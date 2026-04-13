//
//  SearchCoordinator.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/13/26.
//

import UIKit

protocol SearchCoordinatorDelegate: AnyObject {
  func searchCoordinatorDidFinish(_ coordinator: SearchCoordinator)
}

final class SearchCoordinator: Coordinator {
  var navigationController: UINavigationController
  var childCoordinators: [Coordinator] = []
  weak var delegate: SearchCoordinatorDelegate?
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    let networkService = NetworkService()
    let repository = MovieRepository(networkService: networkService)
    let useCase = SearchMoviesUseCase(repository: repository)
    let viewModel = SearchViewModel(searchMoviesUseCase: useCase)
    
    let vc = SearchViewController(viewModel: viewModel)
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
    delegate?.searchCoordinatorDidFinish(self)
  }
}

// MARK: - DetailCoordinatorDelegate
extension SearchCoordinator: DetailCoordinatorDelegate {
  func detailCoordinatorDidFinish(_ coordinator: DetailCoordinator) {
    childCoordinators.removeAll { $0 === coordinator }
  }
}
