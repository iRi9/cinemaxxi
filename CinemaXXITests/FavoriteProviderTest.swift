//
//  FavoriteProviderTest.swift
//  CinemaXXITests
//
//  Created by Giri Bahari on 21/01/22.
//

import XCTest
@testable import CinemaXXI

class FavoriteProviderTest: XCTestCase {

    var sut: FavoriteProvider!

    override func setUp() {
        super.setUp()
        let coreDataManager = CoreDataManager(.inMemory)
        sut = FavoriteProvider(backgroundContext: coreDataManager.backgroundContext)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_create_favorite_movie() {
        let favoriteMovie = Favorite(id: Int64(524434), poster: Data(), title: "Eternal", overview: "-", releaseDate: "2021-12-10", posterUrl: "")

        let expect = XCTestExpectation(description: "callback")

        sut.createFavorite(favoriteMovie) { status  in
            expect.fulfill()
            XCTAssertTrue(status)
        }

        wait(for: [expect], timeout: 3.1)
    }

    func test_get_favorite_movies() {
        let favoriteMovie = Favorite(id: Int64(524434), poster: Data(), title: "Eternal", overview: "-", releaseDate: "2021-12-10", posterUrl: "")
        let favoriteMovie2 = Favorite(id: Int64(5244344), poster: Data(), title: "Eternal", overview: "-", releaseDate: "2021-12-10", posterUrl: "")

        let expect = XCTestExpectation(description: "callback")

        sut.createFavorite(favoriteMovie) { status in
            expect.fulfill()
            XCTAssertTrue(status)
        }

        sut.createFavorite(favoriteMovie2) { status in
            expect.fulfill()
            XCTAssertTrue(status)
        }


        sut.getFavoriteMovies { favoriteMovies in
            expect.fulfill()

            XCTAssertEqual(favoriteMovies.count, 2)
        }
        wait(for: [expect], timeout: 5)
    }

    func test_get_favorite_movie() {
        let favMovie = Favorite(id: Int64(524434), poster: Data(), title: "Eternal", overview: "-", releaseDate: "2021-12-10", posterUrl: "")

        let expect = XCTestExpectation(description: "callback")

        sut.createFavorite(favMovie) { status in
            expect.fulfill()
            XCTAssertTrue(status)
        }

        sut.getFavoriteMovie(favMovie.title!) { favoriteMovie in
            expect.fulfill()

            XCTAssertEqual(favoriteMovie?.title, favMovie.title)
        }

        wait(for: [expect], timeout: 3.1)
    }

    func test_delete_favorite_movie() {
        let favoriteMovie = Favorite(id: Int64(524434), poster: Data(), title: "Eternal", overview: "-", releaseDate: "2021-12-10", posterUrl: "")

        let expect = XCTestExpectation(description: "callback")

        sut.createFavorite(favoriteMovie) { status in
            expect.fulfill()
            XCTAssertTrue(status)
        }

        sut.deleteFavoriteMovie(favoriteMovie.id!) { status in
            expect.fulfill()

            XCTAssertTrue(status)
        }

        wait(for: [expect], timeout: 3.1)
    }

    

}
