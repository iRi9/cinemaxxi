//
//  HomeViewModelTest.swift
//  CinemaXXITests
//
//  Created by Giri Bahari on 19/01/22.
//

import XCTest
@testable import CinemaXXI

class HomeViewModelTest: XCTestCase {
    var sut: HomeViewModel!
    var mockApi: MockApi!
    var movieCategory = "popular"

    override func setUp() {
        super.setUp()
        mockApi = MockApi()
        sut = HomeViewModel(api: mockApi)
    }

    override func tearDown() {
        sut = nil
        mockApi = nil
        super.tearDown()
    }

    func test_fetch_movie() {
        // Given
        mockApi.completeMovies = [Movie]()

        // When
        sut.fetchMovie(category: movieCategory, page: 1)

        // Result
        XCTAssert(mockApi.isFetchMovieCalled)

    }

    func test_fetch_movie_failed() {
        // Given
        let error = ApiError.invalidService

        // When
        sut.fetchMovie(category: movieCategory, page: 1)
        mockApi.fetchMovieFailed()

        // Result
        XCTAssertEqual(sut.alertMessage, error.rawValue)
    }

    func test_loading_when_fetch_movie() {
        // Given
        var loadingStatus = false
        let expect = XCTestExpectation(description: "Loading status updated")
        sut?.updateLoadingStatus = { [weak sut] in
            loadingStatus = sut!.isLoading
            expect.fulfill()
        }

        // When getting data news
        sut.fetchMovie(category: movieCategory, page: 1)
        XCTAssertTrue( loadingStatus )

        // Whwn finish
        mockApi.fetchMovieSuccess()
        XCTAssertFalse( loadingStatus )

        wait(for: [expect], timeout: 1.0)

    }

    func test_create_cell_view_model() {
        // Given
        let movies = StubMovieGenerator().stubMovies()
        mockApi.completeMovies = movies
        let expect = XCTestExpectation(description: "Reload tableview fired")
        sut.reloadTableView = { () in
            expect.fulfill()
        }

        // When
        sut.fetchMovie(category: movieCategory, page: 1)
        mockApi.fetchMovieSuccess()

        // Number of cell equal to news
        XCTAssertEqual(sut.numberOfCells, movies.count)

        wait(for: [expect], timeout: 1.0)
    }

    func test_get_cell_view_model() {
        // Given
        mockApi.completeMovies = StubMovieGenerator().stubMovies()
        sut.fetchMovie(category: movieCategory, page: 1)
        mockApi.fetchMovieSuccess()

        let indexPath = IndexPath(row: 1, section: 0)
        let testMovie = mockApi.completeMovies[indexPath.row]

        // When
        let cellViewModel = sut.getCellViewModel(at: indexPath)

        XCTAssertEqual(cellViewModel.title, testMovie.title)

    }

}

class MockApi: ApiServiceProtocol {
    var isFetchMovieCalled = false

    var completeClosure: ((Bool, [Movie], ApiError?) -> Void)!
    var completeMovies = [Movie]()

    func fetchMovie(category: String, page: Int, complete: @escaping (Bool, [Movie], ApiError?) -> Void) {
        isFetchMovieCalled = true
        completeClosure = complete
    }

    func fetchMovieSuccess() {
        completeClosure(true, completeMovies, nil)
    }

    func fetchMovieFailed() {
        completeClosure(false, completeMovies, .invalidService)
    }
}

class StubMovieGenerator {
    func stubMovies() -> [Movie] {
        guard let path = Bundle(for: type(of: self)).path(forResource: "movie", ofType: "json") else {
            fatalError("movie.json not found")
        }
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let movieResponse = try! decoder.decode(MovieResponse.self, from: data)
        return movieResponse.movies
    }
}
