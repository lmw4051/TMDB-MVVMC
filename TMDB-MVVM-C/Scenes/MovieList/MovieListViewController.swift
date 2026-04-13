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
    let availableWidth = view.bounds.width
    
    layout.itemSize = CGSize(
      width: (availableWidth - 48) / 2,
      height: 280
    )
    
    layout.minimumInteritemSpacing = 16
    layout.minimumLineSpacing = 16
    layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    layout.footerReferenceSize = CGSize(width: availableWidth, height: 60)
    
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.translatesAutoresizingMaskIntoConstraints = false
    
    cv.register(
      MovieCell.self,
      forCellWithReuseIdentifier: MovieCell.reuseIdentifier
    )
    
    cv.register(
      SkeletonCell.self,
      forCellWithReuseIdentifier: SkeletonCell.reuseIdentifier
    )
    
    cv.register(
      PaginationFooterView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
      withReuseIdentifier: PaginationFooterView.reuseIdentifier
    )
    
    cv.dataSource = self
    cv.delegate = self
    cv.prefetchDataSource = self
    cv.refreshControl = refreshControl
    return cv
  }()
  
  private lazy var refreshControl: UIRefreshControl = {
    let rc = UIRefreshControl()
    rc.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    return rc
  }()
  
  private lazy var emptyStateView: EmptyStateView = {
    let v = EmptyStateView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.isHidden = true
    v.onRetry = { [weak self] in self?.viewModel.refresh() }
    return v
  }()
  
  // MARK: - Init
  init(viewModel: MovieListViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupSearchButton()
    bindViewModel()
    viewModel.viewDidLoad()
  }
  
  private func setupSearchButton() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .search,
      target: self,
      action: #selector(searchTapped)
    )
  }
      
  // MARK: - Setup
  private func setupUI() {
    title = "Movies"
    view.backgroundColor = .systemBackground
    view.addSubview(collectionView)
    view.addSubview(emptyStateView)
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  private func bindViewModel() {
    viewModel.$movies
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in self?.collectionView.reloadData() }
      .store(in: &cancellables)
    
    viewModel.$listState
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in self?.handleListState(state) }
      .store(in: &cancellables)
  }
  
  private func handleListState(_ state: ListState) {
    refreshControl.endRefreshing()
    emptyStateView.isHidden = true
    collectionView.isHidden = false
    
    switch state {
    case .idle:
      break
      
    case .skeletonLoading:
      collectionView.reloadData()
      
    case .paginationLoading:
      collectionView.reloadData()
      
    case .success:
      collectionView.reloadData()
      
    case .empty:
      emptyStateView.isHidden = false
      collectionView.isHidden = true
      emptyStateView.configure(for: .noData)
      
    case .networkError:
      if viewModel.movies.isEmpty {
        emptyStateView.isHidden = false
        collectionView.isHidden = true
        emptyStateView.configure(for: .noNetwork)
      } else {
        ToastView.show(
          in: view,
          message: "Network Connection Failed",
          type: .error
        )
      }
      
    case .failure(let message):
      if viewModel.movies.isEmpty {
        emptyStateView.isHidden = false
        collectionView.isHidden = true
        emptyStateView.configure(for: .error(message))
      } else {
        ToastView.show(in: view, message: message, type: .error)
      }
      
    case .paginationError(let message):
      ToastView.show(in: view, message: message, type: .warning)
      collectionView.reloadData()
    }
  }
  
  // MARK: - Actions
  @objc private func handleRefresh() {
    viewModel.refresh()
  }
  
  @objc private func searchTapped() {
    coordinator?.showSearch()
  }
}

// MARK: - UICollectionViewDataSource
extension MovieListViewController: UICollectionViewDataSource {
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    switch viewModel.listState {
    case .skeletonLoading:
      return 6
    default:
      return viewModel.movies.count
    }
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    switch viewModel.listState {
    case .skeletonLoading:
      let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: SkeletonCell.reuseIdentifier,
        for: indexPath) as! SkeletonCell
      cell.startShimmer()
      return cell
      
    default:
      let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: MovieCell.reuseIdentifier,
        for: indexPath
      ) as! MovieCell
      
      cell.configure(with: viewModel.movies[indexPath.item])
      
      return cell
    }
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath
  ) -> UICollectionReusableView {
    let footer = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      withReuseIdentifier: PaginationFooterView.reuseIdentifier,
      for: indexPath
    ) as! PaginationFooterView
    
    footer.onRetry = { [weak self] in self?.viewModel.retryPagination() }
    
    switch viewModel.listState {
    case .paginationLoading:
      footer.configure(state: .loading)
    case .paginationError:
      footer.configure(state: .error)
    case .success where !viewModel.canLoadMore:
      footer.configure(state: .end)
    default:
      footer.configure(state: .hidden)
    }
    
    return footer
  }
}

// MARK: - UICollectionViewDelegate
extension MovieListViewController: UICollectionViewDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    guard case .success = viewModel.listState else { return }
    let movie = viewModel.movies[indexPath.item]
    coordinator?.showDetail(movieId: movie.id)
  }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension MovieListViewController: UICollectionViewDataSourcePrefetching {
  func collectionView(
    _ collectionView: UICollectionView,
    prefetchItemsAt indexPaths: [IndexPath]
  ) {
    guard let maxIndex = indexPaths.map({ $0.item }).max() else { return }
    viewModel.loadNextPageIfNeeded(currentIndex: maxIndex)
  }
}
