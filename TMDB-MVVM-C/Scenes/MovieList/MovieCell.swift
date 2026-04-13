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
    label.numberOfLines = 0
    label.setContentCompressionResistancePriority(.required, for: .vertical)
    return label
  }()
  
  private lazy var ratingLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 12, weight: .regular)
    label.textColor = .secondaryLabel
    label.setContentCompressionResistancePriority(.required, for: .vertical)
    return label
  }()
  
  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  // MARK: - Setup
  private func setupUI() {
    contentView.addSubview(posterImageView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(ratingLabel)
    
    NSLayoutConstraint.activate([
      posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      posterImageView.heightAnchor.constraint(
        equalTo: contentView.widthAnchor, multiplier: 1.5
      ),
      
      titleLabel.topAnchor.constraint(
        equalTo: posterImageView.bottomAnchor,
        constant: 8
      ),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      
      ratingLabel.topAnchor.constraint(
        equalTo: titleLabel.bottomAnchor,
        constant: 4
      ),
      
      ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      
      ratingLabel.bottomAnchor.constraint(
        equalTo: contentView.bottomAnchor,
        constant: -8
      )
    ])
  }
  
  // MARK: - Configure
  func configure(with movie: Movie) {
    titleLabel.text = movie.title
    ratingLabel.text = "⭐ \(String(format: "%.1f", movie.voteAverage))"
    posterImageView.loadImage(from: movie.posterPath)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    posterImageView.image = nil
    titleLabel.text = nil
    ratingLabel.text = nil
  }
}
