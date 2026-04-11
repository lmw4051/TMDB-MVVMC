//
//  MovieDetailViewController.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import UIKit

final class MovieDetailViewController: UIViewController {
  // MARK: - Properties
  weak var coordinator: DetailCoordinator?
  private let viewModel: MovieDetailViewModel
  
  // MARK: - Init
  init(viewModel: MovieDetailViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    title = "Movie Detail"
  }
}
