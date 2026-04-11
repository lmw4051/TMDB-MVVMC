//
//  MovieListViewController.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import UIKit
import Combine

final class MovieListViewController: UIViewController {
  // MARK: - Properties
  weak var coordinator: MovieListCoordinator?
  private let viewModel: MovieListViewModel
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - UI Components
  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(
      width: (UIScreen.main.bounds.width - 48) / 2,
      height: 280
    )
    
    layout.minimumInteritemSpacing = 16
    layout.minimumLineSpacing = 16
    layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.translatesAutoresizingMaskIntoConstraints = false
    cv.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIdentifier)
    cv.dataSource = self
    cv.delegate = self
    cv.prefetchDataSource = self
    return cv
  }()
  
  private lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: .large)
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.hidesWhenStopped = true
    return indicator
  }()
  
  private lazy var refreshControl: UIRefreshControl = {
    let rc = UIRefreshControl()
    rc.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    return rc
  }()
  
  // MARK: - Init
  init(viewModel: MovieListViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    bindViewModel()
    viewModel.viewDidLoad()
  }
  
  // MARK: - Setup
  private func setupUI() {
    title = "Movies"
    view.backgroundColor = .systemBackground
    
    collectionView.refreshControl = refreshControl
    view.addSubview(collectionView)
    view.addSubview(activityIndicator)
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
  
  private func bindViewModel() {
    viewModel.$movies
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.collectionView.reloadData()
      }
      .store(in: &cancellables)
    
    viewModel.$state
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in
        self?.handleState(state)
      }
      .store(in: &cancellables)
  }
  
  private func handleState(_ state: ViewModelState<[Movie]>) {
    switch state {
    case .idle:
      break
    case .loading:
      if viewModel.movies.isEmpty {
        activityIndicator.startAnimating()
      }
    case .success:
      activityIndicator.stopAnimating()
      refreshControl.endRefreshing()
    case .failure(let message):
      activityIndicator.stopAnimating()
      refreshControl.endRefreshing()
      showErrorAlert(message: message)
    }
  }
  
  private func showErrorAlert(message: String) {
    let alert = UIAlertController(title: "Error",
                                  message: message,
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
  
  // MARK: - Actions
  @objc private func handleRefresh() {
    viewModel.refresh()
  }
}

// MARK: - UICollectionViewDataSource
extension MovieListViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    viewModel.movies.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as? MovieCell else {
      return UICollectionViewCell()
    }
    
    cell.configure(with: viewModel.movies[indexPath.item])
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension MovieListViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let movie = viewModel.movies[indexPath.item]
    coordinator?.showDetail(movieId: movie.id)
  }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension MovieListViewController: UICollectionViewDataSourcePrefetching {
  func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    guard let maxIndex = indexPaths.map({ $0.item }).max() else { return }
    viewModel.loadNextPageIfNeeded(currentIndex: maxIndex)
  }
}
