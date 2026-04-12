//
//  EmptyStateView.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/12/26.
//

import UIKit

final class EmptyStateView: UIView {
  enum State {
    case noNetwork
    case noData
    case error(String)
  }
  
  private lazy var iconLabel: UILabel = {
    let l = UILabel()
    l.font = .systemFont(ofSize: 48)
    l.textAlignment = .center
    l.translatesAutoresizingMaskIntoConstraints = false
    return l
  }()
  
  private lazy var titleLabel: UILabel = {
    let l = UILabel()
    l.font = .systemFont(ofSize: 18, weight: .medium)
    l.textAlignment = .center
    l.translatesAutoresizingMaskIntoConstraints = false
    return l
  }()
  
  private lazy var subtitleLabel: UILabel = {
    let l = UILabel()
    l.font = .systemFont(ofSize: 14)
    l.textColor = .secondaryLabel
    l.textAlignment = .center
    l.numberOfLines = 0
    l.translatesAutoresizingMaskIntoConstraints = false
    return l
  }()
  
  private lazy var retryButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.title = "Retry"
    config.cornerStyle = .medium
    let b = UIButton(configuration: config)
    b.translatesAutoresizingMaskIntoConstraints = false
    b.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
    return b
  }()
  
  var onRetry: (() -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  private func setupUI() {
    let stack = UIStackView(arrangedSubviews: [
      iconLabel, titleLabel, subtitleLabel, retryButton
    ])
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = 12
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.setCustomSpacing(24, after: subtitleLabel)
    
    addSubview(stack)
    NSLayoutConstraint.activate([
      stack.centerXAnchor.constraint(equalTo: centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: centerYAnchor),
      stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
    ])
  }
  
  func configure(for state: State) {
    switch state {
    case .noNetwork:
      iconLabel.text = "📡"
      titleLabel.text = "No Connection"
      subtitleLabel.text = "Please check your network connection and try again."
      retryButton.isHidden = false
    case .noData:
      iconLabel.text = "🎬"
      titleLabel.text = "No Movies Available"
      subtitleLabel.text = ""
      retryButton.isHidden = true
    case .error(let message):
      iconLabel.text = "⚠️"
      titleLabel.text = "Failed to Load"
      subtitleLabel.text = message
      retryButton.isHidden = false
    }
  }
}
