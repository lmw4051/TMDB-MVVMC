# MovieBrowser 🎬

A robust, high-performance iOS application for discovering, searching, and managing favorite movies using the TMDB API. Built with Clean Architecture, the MVVM-C design pattern, and modern Swift technologies.

---

## ✨ Features

* **Discover & Pagination:** Browse trending movies with smooth infinite scrolling and automated pagination.
* **Smart Search:** Real-time movie search optimized with a 500ms Combine debounce and duplicate filtering to minimize unnecessary API calls.
* **Offline Favorites:** Save movies to a personal "Favorites" list with swipe-to-delete functionality, persistently stored offline using CoreData.
* **Custom Image Caching:** A highly efficient, custom-built two-level image caching system (Memory via `NSCache` + Disk via `FileManager`) to reduce network usage and ensure smooth UI scrolling.
* **Advanced Error Handling:** Robust network error mapping paired with an Exponential Backoff retry mechanism for unstable internet connections.
* **Premium UI States:** Enhanced user experience featuring Skeleton Loading screens, Empty States, and custom Toast notifications.

---

## 🏗 Architecture

This project strictly adheres to **Clean Architecture** principles and the **MVVM-C (Model-View-ViewModel-Coordinator)** pattern to ensure high testability, scalability, and clear separation of concerns.

* **Domain Layer:** Contains core business logic (`Entities`, `UseCases`, and `Repository Protocols`). It is completely isolated from UI and external frameworks.
* **Data Layer:** Implements the repository protocols. It manages data retrieval from the Network (`URLSession`) and Local Storage (`CoreDataStack`), handling DTO mapping.
* **Presentation Layer:** 100% programmatic `UIKit` (No Storyboards). Utilizes `UICollectionViewCompositionalLayout` for dynamic cell sizing and adaptivity.
* **Coordinator Layer:** Manages all navigation and routing logic, keeping `ViewControllers` completely decoupled from each other.

---

## 🛠 Tech Stack

* **Language:** Swift
* **UI Framework:** UIKit (Programmatic)
* **Concurrency:** Swift Concurrency (`async/await`, `Task`, `@MainActor`)
* **Reactive Programming:** Combine (`@Published`, `CurrentValueSubject`, `debounce`)
* **Local Storage:** CoreData (`NSPersistentContainer`, Background Contexts)
* **Networking:** URLSession
* **CI/CD:** GitHub Actions, Fastlane, SwiftLint

---

## 🚀 Getting Started

### Prerequisites
* Xcode 15.2 or later
* iOS 17.2 Simulator or Device
* A valid TMDB API Key

### Installation & Setup

1. **Clone the repository**
   ```bash
   git clone git@github.com:lmw4051/TMDB-MVVMC.git
   cd TMDB-MVVM-C
