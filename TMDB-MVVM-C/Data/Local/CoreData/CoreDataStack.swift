//
//  CoreDataStack.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/14/26.
//

import CoreData

final class CoreDataStack {
  static let shared = CoreDataStack()
  private init() {}
  
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "TMDB")
    container.loadPersistentStores { _, error in
      if let error {
        fatalError("CoreData failed to load: \(error)")
      }
    }
    
    container.viewContext.automaticallyMergesChangesFromParent = true
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    return container
  }()
  
  var viewContext: NSManagedObjectContext {
    persistentContainer.viewContext
  }
  
  func newBackgroundContext() -> NSManagedObjectContext {
    persistentContainer.newBackgroundContext()
  }
  
  func saveContext() {
    guard viewContext.hasChanges else { return }
    
    do {
      try viewContext.save()
    } catch {
      print("CoreData save error: \(error)")
    }
  }
}
