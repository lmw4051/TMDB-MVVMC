//
//  MovieCell.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/11/26.
//

import UIKit

final class MovieCell: UICollectionViewCell {
  static let reuseIdentifier = "MovieCell"
  
  // MARK: - UI Components
  private lazy var posterImageView: UIImageView = {
    let iv = UIImageView()
    iv.translatesAutoresizingMaskIntoConstraints = false
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = .systemGray5
    iv.layer.cornerRadius = 8
    return iv
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 14, weight: .medium)
    label.numberOfLines = 2
    return label
  }()
  
  private lazy var ratingLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 12, weight: .regular)
    label.textColor = .secondaryLabel
    return label
  }()
  
  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  private func setupUI() {
    contentView.addSubview(posterImageView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(ratingLabel)
    
    NSLayoutConstraint.activate([
      posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      posterImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor,
                                              multiplier: 1.5),
      
      titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor,
                                      constant: 8),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      
      ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                       constant: 4),
      ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    ])
  }
  
  // MARK: - Configure
  func configure(with movie: Movie) {
    titleLabel.text = movie.title
    ratingLabel.text = "⭐ \(String(format: "%.1f", movie.voteAverage))"
    loadImage(from: movie.posterPath)
  }
  
  private func loadImage(from path: String?) {
    guard let path = path else {
      posterImageView.image = nil
      return
    }
    let urlString = "https://image.tmdb.org/t/p/w500\(path)"
    guard let url = URL(string: urlString) else { return }
    
    Task {
      guard let (data, _) = try? await URLSession.shared.data(from: url),
            let image = UIImage(data: data) else { return }
      await MainActor.run {
        self.posterImageView.image = image
      }
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    posterImageView.image = nil
    titleLabel.text = nil
    ratingLabel.text = nil
  }
}
