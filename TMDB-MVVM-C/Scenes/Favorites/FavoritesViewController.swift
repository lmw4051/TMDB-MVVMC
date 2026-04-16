//
//  FavoritesViewController.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/16/26.
//

import UIKit
import Combine

final class FavoritesViewController: UIViewController {
  // MARK: - Properties
  weak var coordinator: FavoritesCoordinator?
  private let viewModel: FavoritesViewModel
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - UI
  private lazy var collectionView: UICollectionView = {
    let cv = UICollectionView(
      frame: .zero,
      collectionViewLayout: CollectionViewLayout.makeMovieGridLayout()
    )
    
    cv.translatesAutoresizingMaskIntoConstraints = false
    cv.register(
      MovieCell.self,
      forCellWithReuseIdentifier: MovieCell.reuseIdentifier
    )
    cv.dataSource = self
    cv.delegate = self
    return cv
  }()
  
  private lazy var emptyStateView: EmptyStateView = {
    let v = EmptyStateView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.isHidden = true
    return v
  }()
  
  private lazy var activityIndicator: UIActivityIndicatorView = {
    let ai = UIActivityIndicatorView(style: .large)
    ai.translatesAutoresizingMaskIntoConstraints = false
    ai.hidesWhenStopped = true
    return ai
  }()
  
  // MARK: - Init
  init(viewModel: FavoritesViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    bindViewModel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.viewWillAppear()
  }
  
  // MARK: - Setup
  private func setupUI() {
    title = "我的最愛"
    view.backgroundColor = .systemBackground
    
    [collectionView, emptyStateView, activityIndicator].forEach {
      view.addSubview($0)
    }
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
  
  
  private func bindViewModel() {
    viewModel.$favoritesState
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in self?.handleFavoritesState(state) }
      .store(in: &cancellables)
  }
  
  // MARK: - State Handling
  private func handleFavoritesState(_ state: FavoritesState) {
    collectionView.isHidden = true
    emptyStateView.isHidden = true
    activityIndicator.stopAnimating()
    
    switch state {
    case .idle:
      break
      
    case .loading:
      activityIndicator.startAnimating()
      
    case .success:
      collectionView.isHidden = false
      collectionView.reloadData()
      
    case .empty:
      emptyStateView.isHidden = false
      emptyStateView.configure(for: .noData)
      
    case .failure(let message):
      emptyStateView.isHidden = false
      emptyStateView.configure(for: .error(message))
    }
  }
}

// MARK: - UICollectionViewDataSource
extension FavoritesViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    viewModel.movies.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
    cell.configure(with: viewModel.movies[indexPath.item])
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension FavoritesViewController: UICollectionViewDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    let movie = viewModel.movies[indexPath.item]
    coordinator?.showDetail(movieId: movie.id)
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    contextMenuConfigurationForItemAt indexPath: IndexPath,
    point: CGPoint
  ) -> UIContextMenuConfiguration? {
    UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
      let remove = UIAction(
        title: "Remove Favorite",
        image: UIImage(systemName: "heart.slash"),
        attributes: .destructive
      ) { [weak self] _ in
        self?.viewModel.removeFavorite(at: indexPath.item)
      }
      return UIMenu(children: [remove])
    }
  }
}
