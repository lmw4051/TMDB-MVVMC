//
//  ImageCache.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/12/26.
//

import UIKit

protocol ImageCacheProtocol {
  func image(for url: URL) -> UIImage?
  func store(_ image: UIImage, for url: URL)
}

final class ImageCache: ImageCacheProtocol {
  static let shared = ImageCache()
  private let memoryCache = NSCache<NSURL, UIImage>()
  private let fileManager = FileManager.default
  private let diskCacheURL: URL
  
  private init() {
    memoryCache.countLimit = 100
    memoryCache.totalCostLimit = 1024 * 1024 * 100
    
    let cacheDir = fileManager.urls(
      for: .cachesDirectory,
      in: .userDomainMask
    )[0]
    
    diskCacheURL = cacheDir.appendingPathComponent("ImageCache")
    
    try? fileManager.createDirectory(
      at: diskCacheURL,
      withIntermediateDirectories: true
    )
  }
  
  func image(for url: URL) -> UIImage? {
    if let cached = memoryCache.object(forKey: url as NSURL) {
      return cached
    }
    
    let diskPath = diskURL(for: url)
    
    guard let data = try? Data(contentsOf: diskPath),
          let image = UIImage(data: data) else { return nil }
    
    memoryCache.setObject(image, forKey: url as NSURL)
    return image
  }
  
  func store(_ image: UIImage, for url: URL) {
    memoryCache.setObject(image, forKey: url as NSURL)
    
    Task.detached(priority: .background) { [weak self] in
      guard let self,
            let data = image.jpegData(compressionQuality: 0.8) else {
        return
      }
      
      try? await data.write(to: self.diskURL(for: url))
    }
  }
  
  // MARK: - Private
  private func diskURL(for url: URL) -> URL {
    let filename = "\(url.absoluteString.hashValue)"
    return diskCacheURL.appendingPathComponent(filename)
  }
}
