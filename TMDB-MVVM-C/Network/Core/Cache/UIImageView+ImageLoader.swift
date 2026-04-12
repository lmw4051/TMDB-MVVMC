//
//  UIImageView+ImageLoader.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/12/26.
//

import UIKit

extension UIImageView {
  private static var taskKey: UInt8 = 0
  
  func loadImage(
    from path: String?,
    baseURL: String = "https://image.tmdb.org/t/p/w500",
    placeholder: UIImage? = nil
  ) {
    image = placeholder ?? .init(systemName: "photo")
    tintColor = .systemGray4
    
    guard let path else { return }
    let urlString = baseURL + path
    
    (objc_getAssociatedObject(self, &Self.taskKey) as? Task<Void, Never>)?.cancel()
    
    let task = Task { @MainActor in
      guard let image = await ImageLoader.shared.loadImage(from: urlString),
            !Task.isCancelled else { return }
      self.image = image
    }
    
    objc_setAssociatedObject(self, &Self.taskKey, task, .OBJC_ASSOCIATION_RETAIN)
  }
}
