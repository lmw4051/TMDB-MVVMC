//
//  ToastView.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/12/26.
//

import UIKit

final class ToastView: UIView {
  enum ToastType {
    case success, error, warning
    
    var backgroundColor: UIColor {
      switch self {
      case .success:
        return .systemGreen
      case .error:
        return .systemRed
      case .warning:
        return .systemOrange
      }
    }
    
    var icon: String {
      switch self {
      case .success:
        return "✓"
      case .error:
        return "✕"
      case .warning:
        return "!"
      }
    }
  }
  
  private init(message: String, type: ToastType) {
    super.init(frame: .zero)
    
    backgroundColor = type.backgroundColor
    layer.cornerRadius = 12
    
    let iconLabel = UILabel()
    iconLabel.text = type.icon
    iconLabel.font = .systemFont(ofSize: 16, weight: .bold)
    iconLabel.textColor = .white
    
    let messageLabel = UILabel()
    messageLabel.text = message
    messageLabel.font = .systemFont(ofSize: 14)
    messageLabel.textColor = .white
    messageLabel.numberOfLines = 0
    
    let stack = UIStackView(arrangedSubviews: [iconLabel, messageLabel])
    stack.spacing = 10
    stack.alignment = .center
    stack.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(stack)
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
      stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
      stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
    ])
  }
  
  required init?(coder: NSCoder) { fatalError() }
}
