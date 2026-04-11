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
  
  private lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: .large)
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.hidesWhenStopped = true
    return indicator
  }()
  
  // MARK: - Init
  init(viewModel: MovieDetailViewModel) {
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
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    if isMovingFromParent {
      coordinator?.didFinish()
    }
  }
  
  // MARK: - Setup
  private func setupUI() {
    view.backgroundColor = .systemBackground
    
    view.addSubview(scrollView)
    view.addSubview(activityIndicator)
    scrollView.addSubview(contentView)
    
    [backdropImageView, titleLabel, ratingLabel,
     genreLabel, overviewLabel].forEach { contentView.addSubview($0) }
    
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
                                            constant: -32),
      
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
  
  private func bindViewModel() {
    viewModel.$movieDetail
      .receive(on: DispatchQueue.main)
      .compactMap { $0 }
      .sink { [weak self] detail in
        self?.updateUI(with: detail)
      }
      .store(in: &cancellables)
    
    viewModel.$state
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in
        self?.handleState(state)
      }
      .store(in: &cancellables)
  }
  
  private func updateUI(with detail: MovieDetail) {
    title = detail.title
    titleLabel.text = detail.title
    ratingLabel.text = "⭐ \(String(format: "%.1f", detail.voteAverage))"
    genreLabel.text = detail.genres.map { $0.name }.joined(separator: " · ")
    overviewLabel.text = detail.overview
    loadBackdrop(from: detail.backdropPath)
  }
  
  private func handleState(_ state: ViewModelState<MovieDetail>) {
    switch state {
    case .idle: break
    case .loading: activityIndicator.startAnimating()
    case .success: activityIndicator.stopAnimating()
    case .failure(let message):
      activityIndicator.stopAnimating()
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
  
  private func loadBackdrop(from path: String?) {
    guard let path = path else { return }
    let urlString = "https://image.tmdb.org/t/p/w780\(path)"
    guard let url = URL(string: urlString) else { return }
    
    Task {
      guard let (data, _) = try? await URLSession.shared.data(from: url),
            let image = UIImage(data: data) else { return }
      await MainActor.run {
        self.backdropImageView.image = image
      }
    }
  }
}
