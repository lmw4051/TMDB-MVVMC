//
//  Coordinator.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/10/26.
//

import UIKit

protocol Coordinator: AnyObject {
  var navigationController: UINavigationController { get set }
  var childCoordinators: [Coordinator] { get set }
  func start()
}
