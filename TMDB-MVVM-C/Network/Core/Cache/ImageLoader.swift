//
//  ImageLoader.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/12/26.
//

import UIKit

final class ImageLoader {
  static let shared = ImageLoader()
  private let cache: ImageCacheProtocol
  private var ongoingTasks: [URL: Task<UIImage?, Never>] = [:]
  
  private init(cache: ImageCacheProtocol = ImageCache.shared) {
    self.cache = cache
  }
  
  @discardableResult
  func loadImage(from urlSring: String) async -> UIImage? {
    guard let url = URL(string: urlSring) else { return nil }
    
    if let cached = cache.image(for: url) { return cached }
    
    if let ongoing = ongoingTasks[url] {
      return await ongoing.value
    }
    
    let task = Task<UIImage?, Never> {
      defer { ongoingTasks.removeValue(forKey: url) }
      
      guard let (data, response) = try? await URLSession.shared.data(from: url),
            let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode),
            let image = UIImage(data: data) else {
        return nil
      }
      
      cache.store(image, for: url)
      return image
    }
    
    ongoingTasks[url] = task
    
    return await task.value
  }
}
