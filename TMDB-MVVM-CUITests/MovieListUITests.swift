//
//  MovieListUITests.swift
//  TMDB-MVVM-CUITests
//
//  Created by David Lee on 4/12/26.
//

import XCTest

final class MovieListUITests: XCTestCase {
  var app: XCUIApplication!
  
  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    app = XCUIApplication()
    app.launchArguments = ["UI_TESTING"]
    app.launch()
  }
  
  override func tearDown() {
    app = nil
    super.tearDown()
  }
  
  func test_movieList_shouldDisplayNavigationTitle() {
    XCTAssertTrue(app.navigationBars["Movies"].exists)
  }
  
  func test_movieList_shouldDisplayCollectionView() {
    let collectionView = app.collectionViews.firstMatch
    XCTAssertTrue(collectionView.waitForExistence(timeout: 5))
  }
  
  func test_movieList_whenCellTapped_shouldNavigateToDetail() {
    let collectionView = app.collectionViews.firstMatch
    XCTAssertTrue(collectionView.waitForExistence(timeout: 5))
    
    let firstCell = collectionView.cells.firstMatch
    XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
    firstCell.tap()
    
    XCTAssertTrue(app.navigationBars.element.waitForExistence(timeout: 5))
  }
}
