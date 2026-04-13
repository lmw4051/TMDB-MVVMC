//
//  DetailSkeletonView.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/13/26.
//

import UIKit

final class DetailSkeletonView: UIView {
  private var shimmerLayers: [CAGradientLayer] = []
  
  private lazy var backdropSkeleton = makeSkeletonView(height: 220, cornerRadius: 0)
  private lazy var titleSkeleton = makeSkeletonView(height: 28, cornerRadius: 6)
  private lazy var titleSkeleton2 = makeSkeletonView(height: 28, cornerRadius: 6, widthMultiplier: 0.6)
  private lazy var ratingSkeleton = makeSkeletonView(height: 18, cornerRadius: 4, widthMultiplier: 0.3)
  private lazy var genreSkeleton = makeSkeletonView(height: 16, cornerRadius: 4, widthMultiplier: 0.5)
  private lazy var line1Skeleton = makeSkeletonView(height: 14, cornerRadius: 4)
  private lazy var line2Skeleton = makeSkeletonView(height: 14, cornerRadius: 4)
  private lazy var line3Skeleton = makeSkeletonView(height: 14, cornerRadius: 4, widthMultiplier: 0.75)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  private func setupUI() {
    let contentStack = UIStackView(arrangedSubviews: [
      backdropSkeleton,
      makePaddedStack([
        titleSkeleton,
        titleSkeleton2,
        ratingSkeleton,
        genreSkeleton,
        makeSpacer(height: 8),
        line1Skeleton,
        line2Skeleton,
        line3Skeleton
      ])
    ])
    
    contentStack.axis = .vertical
    contentStack.spacing = 0
    contentStack.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(contentStack)
    NSLayoutConstraint.activate([
      contentStack.topAnchor.constraint(equalTo: topAnchor),
      contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentStack.trailingAnchor.constraint(equalTo: trailingAnchor)
    ])
  }
  
  func startShimmer() {
    [backdropSkeleton,
     titleSkeleton,
     titleSkeleton2,
     ratingSkeleton,
     genreSkeleton,
     line1Skeleton,
     line2Skeleton,
     line3Skeleton
    ].forEach { view in
      let shimmer = makeShimmerLayer()
      view.layer.addSublayer(shimmer)
      shimmerLayers.append(shimmer)
      
      let animation = CABasicAnimation(keyPath: "locations")
      animation.fromValue = [-1.0, -0.5, 0.0]
      animation.toValue = [1.0, 1.5, 2.0]
      animation.duration = 1.4
      animation.repeatCount = .infinity
      shimmer.add(animation, forKey: "shimmer")
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    shimmerLayers.forEach { $0.frame = $0.superlayer?.bounds ?? .zero }
  }
  
  // MARK: - Helpers
  private func makeSkeletonView(
    height: CGFloat,
    cornerRadius: CGFloat,
    widthMultiplier: CGFloat = 1.0
  ) -> UIView {
    let container = UIView()
    let skeleton = UIView()
    skeleton.backgroundColor = .systemGray5
    skeleton.layer.cornerRadius = cornerRadius
    skeleton.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(skeleton)
    
    NSLayoutConstraint.activate([
      skeleton.topAnchor.constraint(equalTo: container.topAnchor),
      skeleton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
      skeleton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      skeleton.heightAnchor.constraint(equalToConstant: height),
      skeleton.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: widthMultiplier)
    ])
    return container
  }
  
  private func makePaddedStack(_ views: [UIView]) -> UIView {
    let stack = UIStackView(arrangedSubviews: views)
    stack.axis = .vertical
    stack.spacing = 10
    
    let container = UIView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
      stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
      stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
      stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
    ])
    return container
  }
  
  private func makeSpacer(height: CGFloat) -> UIView {
    let v = UIView()
    v.heightAnchor.constraint(equalToConstant: height).isActive = true
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
