//
//  FavoriteRepository.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/14/26.
//

import CoreData

final class FavoriteRepository: FavoriteRepositoryProtocol {
  private let coreDataStack: CoreDataStack
  
  init(coreDataStack: CoreDataStack = .shared) {
    self.coreDataStack = coreDataStack
  }
  
  // MARK: - Add
  func addFavorite(_ movie: Movie) async throws {
    let context = coreDataStack.newBackgroundContext()
    
    try await context.perform {
      let existing = try self.fetchEntity(movieId: movie.id, context: context)
      guard existing == nil else { return }
      
      let entity = FavoriteMovieEntity(context: context)
      entity.id = Int64(movie.id)
      entity.title = movie.title
      entity.overview = movie.overview
      entity.posterPath = movie.posterPath
      entity.voteAverage = movie.voteAverage
      entity.releaseDate = movie.releaseDate
      entity.createdAt = Date()
      
      try context.save()
    }
  }
  
  // MARK: - Remove
  func removeFavorite(movieId: Int) async throws {
    let context = coreDataStack.newBackgroundContext()
    
    try await context.perform {
      guard let entity = try self.fetchEntity(movieId: movieId, context: context) else {
        return
      }
      
      context.delete(entity)
      try context.save()
    }
  }
  
  // MARK: - Get All
  func getFavorites() async throws -> [Movie] {
    let context = coreDataStack.viewContext
    
    return try await context.perform {
      let request = FavoriteMovieEntity.fetchRequest()
      request.sortDescriptors = [
        NSSortDescriptor(key: "createdAt", ascending: false)
      ]
      
      let entities = try context.fetch(request)
      return entities.map { self.toDomain($0) }
    }
  }
  
  // MARK: - Check
  func checkFavorite(movieId: Int) async throws -> Bool {
    let context = coreDataStack.viewContext
    
    return try await context.perform {
      let entry = try self.fetchEntity(movieId: movieId, context: context)
      return entry != nil
    }
  }
  
  // MARK: - Private Helpers
  private func fetchEntity(
    movieId: Int,
    context: NSManagedObjectContext
  ) throws -> FavoriteMovieEntity? {
    let request = FavoriteMovieEntity.fetchRequest()
    request.predicate = NSPredicate(format: "id == %d", movieId)
    request.fetchLimit = 1
    return try context.fetch(request).first
  }
  
  private func toDomain(_ entity: FavoriteMovieEntity) -> Movie {
    Movie(
      id: Int(entity.id),
      title: entity.title ?? "",
      overview: entity.overview ?? "",
      posterPath: entity.posterPath,
      voteAverage: entity.voteAverage,
      releaseDate: entity.releaseDate ?? ""
    )
  }
}
