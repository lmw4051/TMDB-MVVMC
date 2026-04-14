//
//  SkeletonView.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/12/26.
//

import UIKit

final class SkeletonCell: UICollectionViewCell {
  static let reuseIdentifier = "SkeletonCell"
  
  private lazy var posterSkeleton = makeSkeletonView(cornerRadius: 8)
  private lazy var titleSkeleton = makeSkeletonView(cornerRadius: 8)
  private lazy var ratingSkeleton = makeSkeletonView(cornerRadius: 8)
  private var shimmerLayers: [CAGradientLayer] = []
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  private func setupUI() {
    [posterSkeleton, titleSkeleton, ratingSkeleton].forEach {
      contentView.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    NSLayoutConstraint.activate([
      posterSkeleton.topAnchor.constraint(equalTo: contentView.topAnchor),
      posterSkeleton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      posterSkeleton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      posterSkeleton.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.5),
      
      titleSkeleton.topAnchor.constraint(equalTo: posterSkeleton.bottomAnchor, constant: 8),
      titleSkeleton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      titleSkeleton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      titleSkeleton.heightAnchor.constraint(equalToConstant: 14),
      
      ratingSkeleton.topAnchor.constraint(equalTo: titleSkeleton.bottomAnchor, constant: 6),
      ratingSkeleton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      ratingSkeleton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5),
      ratingSkeleton.heightAnchor.constraint(equalToConstant: 12)
    ])
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    shimmerLayers.forEach { $0.frame = $0.superlayer?.bounds ?? .zero }
  }
  
  func startShimmer() {
    [posterSkeleton, titleSkeleton, ratingSkeleton].forEach { view in
      let shimmer = makeShimmerLayer()
      view.layer.addSublayer(shimmer)
      shimmerLayers.append(shimmer)
      
      let animation = CABasicAnimation(keyPath: "locations")
      animation.fromValue = [-1.0, -0.5, 0.0]
      animation.toValue = [1.0,  1.5,  2.0]
      animation.duration = 1.4
      animation.repeatCount = .infinity
      shimmer.add(animation, forKey: "shimmer")
    }
  }
  
  private func makeSkeletonView(cornerRadius: CGFloat) -> UIView {
    let v = UIView()
    v.backgroundColor = .systemGray5
    v.layer.cornerRadius = cornerRadius
    return v
  }
  
  private func makeShimmerLayer() -> CAGradientLayer {
    let layer = CAGradientLayer()
    layer.colors = [
      UIColor.systemGray5.cgColor,
      UIColor.systemGray4.cgColor,
      UIColor.systemGray5.cgColor
    ]
    layer.locations = [-1.0, -0.5, 0.0]
    layer.startPoint = CGPoint(x: 0, y: 0.5)
    layer.endPoint = CGPoint(x: 1, y: 0.5)
    return layer
  }
}
