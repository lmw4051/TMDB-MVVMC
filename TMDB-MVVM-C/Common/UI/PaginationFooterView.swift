//
//  PaginationFooterView.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/12/26.
//

import UIKit

final class PaginationFooterView: UICollectionReusableView {
  static let reuseIdentifier = "PaginationFooterView"
  
  enum State {
    case loading
    case error
    case end
    case hidden
  }
  
  private lazy var activityIndicator: UIActivityIndicatorView = {
    let ai = UIActivityIndicatorView(style: .medium)
    ai.translatesAutoresizingMaskIntoConstraints = false
    return ai
  }()
  
  private lazy var messageLabel: UILabel = {
    let l = UILabel()
    l.font = .systemFont(ofSize: 13)
    l.textColor = .secondaryLabel
    l.textAlignment = .center
    l.translatesAutoresizingMaskIntoConstraints = false
    return l
  }()
  
  private lazy var retryButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.title = "重試載入"
    config.baseForegroundColor = .systemBlue
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
    [activityIndicator, messageLabel, retryButton].forEach { addSubview($0) }
    
    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
      
      messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
      
      retryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
      retryButton.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }
  
  func configure(state: State) {
    activityIndicator.stopAnimating()
    messageLabel.isHidden = true
    retryButton.isHidden = true
    isHidden = false
    
    switch state {
    case .loading:
      activityIndicator.startAnimating()
    case .error:
      retryButton.isHidden = false
    case .end:
      messageLabel.isHidden = false
      messageLabel.text = "已顯示全部電影"
    case .hidden:
      isHidden = true
    }
  }
  
  @objc private func retryTapped() { onRetry?() }
}
