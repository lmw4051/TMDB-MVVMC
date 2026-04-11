//
//  DetailCoordinator.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import UIKit

// MARK: - Delegate Protocol
protocol DetailCoordinatorDelegate: AnyObject {
  func detailCoordinatorDidFinish(_ coordinator: DetailCoordinator)
}

final class DetailCoordinator: Coordinator {
  var navigationController: UINavigationController
  var childCoordinators: [Coordinator] = []
  weak var delegate: DetailCoordinatorDelegate?
  
  private let movieId: Int
  
  init(navigationController: UINavigationController, movieId: Int) {
    self.navigationController = navigationController
    self.movieId = movieId
  }
  
  func start() {
    let networkService = NetworkService()
    let repository = MovieRepository(networkService: networkService)
    let useCase = FetchMovieDetailUseCase(repository: repository)
    let viewModel = MovieDetailViewModel(
      fetchMovieDetailUseCase: useCase,
      movieId: movieId
    )
    
    let vc = MovieDetailViewController(viewModel: viewModel)
    vc.coordinator = self
    navigationController.pushViewController(vc, animated: true)
  }
  
  func didFinish() {
    delegate?.detailCoordinatorDidFinish(self)
  }
}
