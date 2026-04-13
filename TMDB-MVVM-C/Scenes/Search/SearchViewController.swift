//
//  SearchViewController.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/13/26.
//

import UIKit
import Combine

final class SearchViewController: UIViewController {
  // MARK: - Properties
  weak var coordinator: SearchCoordinator?
  private let viewModel: SearchViewModel
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - UI
  private lazy var searchController: UISearchController = {
    let sc = UISearchController(searchResultsController: nil)
    sc.searchBar.placeholder = "Search movies..."
    sc.obscuresBackgroundDuringPresentation = false
    sc.searchBar.delegate = self
    return sc
  }()
  
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
    layout.footerReferenceSize = CGSize(
      width: availableWidth,
      height: 60
    )
    
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
    return cv
  }()
  
  private lazy var emptyStateView: EmptyStateView = {
    let v = EmptyStateView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.isHidden = true
    v.onRetry = { [weak self] in
      guard let query = self?.searchController.searchBar.text else { return }
      self?.viewModel.searchQuery.send(query)
    }
    return v
  }()
  
  private lazy var idleStateView: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    
    let iconLabel = UILabel()
    iconLabel.text = "🔍"
    iconLabel.font = .systemFont(ofSize: 48)
    iconLabel.textAlignment = .center
    
    let titleLabel = UILabel()
    titleLabel.text = "Search Movies"
    titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
    titleLabel.textAlignment = .center
    
    let subtitleLabel = UILabel()
    subtitleLabel.text = "Enter a movie name to start searching"
    subtitleLabel.font = .systemFont(ofSize: 14)
    subtitleLabel.textColor = .secondaryLabel
    subtitleLabel.textAlignment = .center
    
    let stack = UIStackView(arrangedSubviews: [iconLabel, titleLabel, subtitleLabel])
    stack.axis = .vertical
    stack.spacing = 12
    stack.translatesAutoresizingMaskIntoConstraints = false
    
    v.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.centerXAnchor.constraint(equalTo: v.centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: v.centerYAnchor)
    ])
    return v
  }()
  
  // MARK: - Init
  init(viewModel: SearchViewModel) {
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
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    searchController.searchBar.becomeFirstResponder()
  }
  
  // MARK: - Setup
  private func setupUI() {
    title = "Search"
    view.backgroundColor = .systemBackground
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    definesPresentationContext = true
    
    [collectionView, emptyStateView, idleStateView].forEach {
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
      
      idleStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      idleStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      idleStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      idleStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  // MARK: - Binding
  private func bindViewModel() {
    viewModel.$searchState
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in self?.handleSearchState(state) }
      .store(in: &cancellables)
  }
  
  // MARK: - State Handling
  private func handleSearchState(_ state: SearchState) {
    collectionView.isHidden = true
    emptyStateView.isHidden = true
    idleStateView.isHidden = true
    
    switch state {
    case .idle:
      idleStateView.isHidden = false
      
    case .skeletonLoading:
      collectionView.isHidden = false
      collectionView.reloadData()
      
    case .success:
      collectionView.isHidden = false
      collectionView.reloadData()
      
    case .paginationLoading, .paginationError:
      collectionView.isHidden = false
      collectionView.reloadData()
      
    case .empty:
      emptyStateView.isHidden = false
      emptyStateView.configure(for: .noData)
      
    case .networkError:
      emptyStateView.isHidden = false
      emptyStateView.configure(for: .noNetwork)
      
    case .failure(let message):
      emptyStateView.isHidden = false
      emptyStateView.configure(for: .error(message))
    }
  }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    viewModel.searchQuery.send(searchText)
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    viewModel.searchQuery.send("")
  }
}

// MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    switch viewModel.searchState {
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
    switch viewModel.searchState {
    case .skeletonLoading:
      let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: SkeletonCell.reuseIdentifier,
        for: indexPath
      ) as! SkeletonCell
      
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
    
    switch viewModel.searchState {
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
extension SearchViewController: UICollectionViewDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    guard case .success = viewModel.searchState else { return }
    let movie = viewModel.movies[indexPath.item]
    coordinator?.showDetail(movieId: movie.id)
  }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension SearchViewController: UICollectionViewDataSourcePrefetching {
  func collectionView(
    _ collectionView: UICollectionView,
    prefetchItemsAt indexPaths: [IndexPath]
  ) {
    guard let maxIndex = indexPaths.map({ $0.item }).max() else { return }
    viewModel.loadNextPageIfNeeded(currentIndex: maxIndex)
  }
}
