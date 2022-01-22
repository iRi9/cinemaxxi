//
//  DetailViewModelTest.swift
//  CinemaXXITests
//
//  Created by Giri Bahari on 20/01/22.
//

import XCTest
@testable import CinemaXXI

class DetailViewModelTest: XCTestCase {
    var sut: DetailViewModel!
    var mockDetailApi: MockDetailApi!
    var movieId: Int!

    override func setUp() {
        super.setUp()
        mockDetailApi = MockDetailApi()
        sut = DetailViewModel(api: mockDetailApi)
        movieId = 524434
    }

    override func tearDown() {
        sut = nil
        mockDetailApi = nil
        movieId = nil
        super.tearDown()
    }

    func test_fetch_detail_success() {

        // When
        sut.fetchDetailMovie(id: movieId)

        // Result
        XCTAssert(mockDetailApi.isFetchDetailCalled)
    }

    func test_fetch_detail_failed() {
        // Given
        let error = ApiError.invalidService

        // When
        sut.fetchDetailMovie(id: movieId)
        mockDetailApi.fetchDetailFailed()

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

        // When
        sut.fetchDetailMovie(id: movieId)

        // Then
        XCTAssertTrue( loadingStatus )

        wait(for: [expect], timeout: 1.0)

    }


}

class MockDetailApi: DetailApiServiceProtocol {

    var isFetchDetailCalled = false
    var isFetchReviewsCalled = false
    var completeDetailClosure: ((Bool, Movie?, ApiError?) -> Void)!
    var completeReviewClosure: ((Bool, [Review], ApiError?) -> Void)!
    var completeMovieDetail = Movie(id: 524434, posterPath: "", title: "Eternal", overview: "", releaseDate: "")
    var completeReview = [Review]()

    func fetchDetail(id: Int, complete: @escaping (Bool, Movie?, ApiError?) -> Void) {
        isFetchDetailCalled = true
        completeDetailClosure = complete
    }

    func fetchDetailSuccess() {
        completeDetailClosure(true, completeMovieDetail, nil)
    }

    func fetchDetailFailed() {
        completeDetailClosure(false, completeMovieDetail, .invalidService)
    }

    func fetchReview(id: Int, page: Int, complete: @escaping (Bool, [Review], ApiError?) -> Void) {
        isFetchReviewsCalled = true
        completeReviewClosure = complete
    }

    func fetchReviewSuccess() {
        completeReviewClosure(true, completeReview, nil)
    }

    func fetchReviewFailed() {
        completeReviewClosure(false, completeReview, .invalidService)
    }

}
