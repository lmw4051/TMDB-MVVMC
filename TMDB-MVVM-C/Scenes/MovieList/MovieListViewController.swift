//
//  MovieListViewController.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import UIKit

final class MovieListViewController: UIViewController {
  // MARK: - Properties
  weak var coordinator: MovieListCoordinator?
  private let viewModel: MovieListViewModel
  
  // MARK: - Init
  init(viewModel: MovieListViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    title = "Movies"
  }
}
