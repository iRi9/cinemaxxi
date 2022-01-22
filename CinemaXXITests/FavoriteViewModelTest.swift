//
//  FavoriteViewModelTest.swift
//  CinemaXXITests
//
//  Created by Giri Bahari on 21/01/22.
//

import XCTest
import CoreData
@testable import CinemaXXI

class FavoriteViewModelTest: XCTestCase {

    var sut: FavoriteViewModel!
    var favoritProvider: FavoriteProvider!

    override func setUp() {
        super.setUp()
        let coreDataManager = CoreDataManager(.inMemory)
        favoritProvider = FavoriteProvider(backgroundContext: coreDataManager.backgroundContext)
        sut = FavoriteViewModel(favoriteProvider: favoritProvider)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_get_favorite_movies() {
        // Given
        var loadingStatus = false
        let expect = XCTestExpectation(description: "Loading status updated")
        sut?.updateLoadingStatus = { [weak sut] in
            loadingStatus = sut!.isLoading
            expect.fulfill()
        }

        // When
        sut.getFavoriteMovies()

        // Then
        XCTAssertTrue(loadingStatus)

        wait(for: [expect], timeout: 1.0)
    }

}
