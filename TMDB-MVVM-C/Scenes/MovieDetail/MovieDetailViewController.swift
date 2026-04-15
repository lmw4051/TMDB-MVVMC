//
//  MovieDetailViewController.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import UIKit
import Combine

final class MovieDetailViewController: UIViewController {
  // MARK: - Properties
  weak var coordinator: DetailCoordinator?
  private let viewModel: MovieDetailViewModel
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - UI Components
  private lazy var scrollView: UIScrollView = {
    let sv = UIScrollView()
    sv.translatesAutoresizingMaskIntoConstraints = false
    return sv
  }()
  
  private lazy var contentView: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }()
  
  private lazy var backdropImageView: UIImageView = {
    let iv = UIImageView()
    iv.translatesAutoresizingMaskIntoConstraints = false
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = .systemGray5
    return iv
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 24, weight: .bold)
    label.numberOfLines = 0
    return label
  }()
  
  private lazy var ratingLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 16, weight: .medium)
    label.textColor = .secondaryLabel
    return label
  }()
  
  private lazy var genreLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 14, weight: .regular)
    label.textColor = .secondaryLabel
    label.numberOfLines = 0
    return label
  }()
  
  private lazy var overviewLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 16, weight: .regular)
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    return label
  }()
  
  private lazy var skeletonView: DetailSkeletonView = {
    let v = DetailSkeletonView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.isHidden = true
    return v
  }()
  
  private lazy var emptyStateView: EmptyStateView = {
    let v = EmptyStateView()
    v.translatesAutoresizingMaskIntoConstraints = false
    v.isHidden = true
    v.onRetry = { [weak self] in self?.viewModel.retry() }
    return v
  }()
  
  private lazy var favoriteButton: UIBarButtonItem = {
    UIBarButtonItem(
      image: UIImage(systemName: "heart"),
      style: .plain,
      target: self,
      action: #selector(favoriteTapped)
    )
  }()
  
  // MARK: - Init
  init(viewModel: MovieDetailViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupFavoriteButton()
    bindViewModel()
    viewModel.viewDidLoad()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    if isMovingFromParent {
      coordinator?.didFinish()
    }
  }
  
  // MARK: - Setup
  private func setupUI() {
    view.backgroundColor = .systemBackground
    
    // ScrollView（正式內容）
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    [backdropImageView, titleLabel, ratingLabel,
     genreLabel, overviewLabel].forEach { contentView.addSubview($0) }
    
    // Skeleton & EmptyState 疊在最上層
    view.addSubview(skeletonView)
    view.addSubview(emptyStateView)
    
    setupScrollViewConstraints()
    setupSkeletonConstraints()
    setupEmptyStateConstraints()
  }
  
  private func setupFavoriteButton() {
    navigationItem.rightBarButtonItem = favoriteButton
  }
  
  private func setupScrollViewConstraints() {
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      
      backdropImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      backdropImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      backdropImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      backdropImageView.heightAnchor.constraint(equalToConstant: 220),
      
      titleLabel.topAnchor.constraint(equalTo: backdropImageView.bottomAnchor,
                                      constant: 16),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                          constant: 16),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                           constant: -16),
      
      ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                       constant: 8),
      ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                           constant: 16),
      
      genreLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor,
                                      constant: 8),
      genreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                          constant: 16),
      genreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                           constant: -16),
      
      overviewLabel.topAnchor.constraint(equalTo: genreLabel.bottomAnchor,
                                         constant: 16),
      overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                             constant: 16),
      overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                              constant: -16),
      overviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                            constant: -32)
    ])
  }
  
  private func setupSkeletonConstraints() {
    NSLayoutConstraint.activate([
      skeletonView.topAnchor.constraint(equalTo: view.topAnchor),
      skeletonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      skeletonView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
  }
  
  private func setupEmptyStateConstraints() {
    NSLayoutConstraint.activate([
      emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  private func bindViewModel() {
    viewModel.$detailState
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in self?.handleDetailState(state) }
      .store(in: &cancellables)
    
    viewModel.$isFavorite
      .receive(on: DispatchQueue.main)
      .sink { [weak self] isFavorite in
        self?.updateFavoriteButton(isFavorite: isFavorite)
      }
      .store(in: &cancellables)
  }
  
  // MARK: - State Handling
  private func handleDetailState(_ state: DetailState) {
    scrollView.isHidden = true
    skeletonView.isHidden = true
    emptyStateView.isHidden = true
    
    switch state {
    case .idle:
      break
      
    case .skeletonLoading:
      skeletonView.isHidden = false
      skeletonView.startShimmer()
      
    case .success(let detail):
      scrollView.isHidden = false
      updateUI(with: detail)
      
    case .networkError:
      emptyStateView.isHidden = false
      emptyStateView.configure(for: .noNetwork)
      
    case .failure(let message):
      emptyStateView.isHidden = false
      emptyStateView.configure(for: .error(message))
    }
  }
  
  // MARK: - UI Update
  private func updateUI(with detail: MovieDetail) {
    title = detail.title
    titleLabel.text = detail.title
    ratingLabel.text = "⭐ \(String(format: "%.1f", detail.voteAverage))"
    genreLabel.text = detail.genres.map { $0.name }.joined(separator: " · ")
    overviewLabel.text = detail.overview
    backdropImageView.loadImage(
      from: detail.backdropPath,
      baseURL: "https://image.tmdb.org/t/p/w780"
    )
  }
  
  private func updateFavoriteButton(isFavorite: Bool) {
    let imageName = isFavorite ? "heart.fill" : "heart"
    favoriteButton.image = UIImage(systemName: imageName)
    favoriteButton.tintColor = isFavorite ? .systemRed : .systemGray
  }
  
  // MARK: - Actions
  @objc private func favoriteTapped() {
    viewModel.toggleFavorite()
    
    let feedback = UIImpactFeedbackGenerator(style: .medium)
    feedback.impactOccurred()
  }
}
