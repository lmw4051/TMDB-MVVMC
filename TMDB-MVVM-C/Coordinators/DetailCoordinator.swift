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
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    
  }
}
