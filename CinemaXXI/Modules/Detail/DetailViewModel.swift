//
//  DetailViewModel.swift
//  CinemaXXI
//
//  Created by Giri Bahari on 20/01/22.
//

import Foundation

class DetailViewModel {
    private var api: DetailApiServiceProtocol
    private var cellViewModels: [DetailMovieCellViewModel] = [DetailMovieCellViewModel]() {
        didSet {
            self.reloadTableView?()
        }
    }
    var isLoading: Bool = false {
        didSet {
            updateLoadingStatus?()
        }
    }
    var alertMessage: String? {
        didSet {
            self.showAlert?()
        }
    }
    var numberOfCells: Int {
        return cellViewModels.count
    }

    var reloadTableView: (() -> Void)?
    var showAlert: (() -> Void)?
    var updateLoadingStatus: (() -> Void)?

    init(api: DetailApiServiceProtocol = DetailApiService()) {
        self.api = api
    }

    func fetchDetailMovie(id: Int) {
        isLoading = true
        api.fetchDetail(id: id) { [weak self] status, detail, error in
            if let error = error {
                self?.isLoading = false
                self?.alertMessage = error.rawValue
            } else {
                guard let detailMovie = detail else { return }
                self?.fetchReview(id: id, page: 1, movie: detailMovie)
            }
        }
    }

    private func fetchReview(id: Int, page: Int, movie: Movie) {
        api.fetchReview(id: id, page: page) { [weak self] status, reviews, error in
            self?.isLoading = false
            if let error = error {
                self?.alertMessage = error.rawValue
            } else {
                self?.processDetailViewModel(movie: movie, reviews: reviews)
            }
        }
    }

    private func processDetailViewModel(movie: Movie, reviews: [Review]) {
        var tempCellViewModel: [DetailMovieCellViewModel] = [
            DetailMovieCellViewModel(title: movie.title, date: movie.releaseDate, overview: movie.overview, posterUrl: "https://image.tmdb.org/t/p/w185\(movie.posterPath)", name: "", review: "", type: .movie),
            DetailMovieCellViewModel(title: "Review", date: "", overview: "", posterUrl: "", name: "", review: "", type: .sparator)
        ]

        for review in reviews {
            tempCellViewModel.append(createDetailMovieCellViewModel(review: review))
        }

        self.cellViewModels = tempCellViewModel
    }

    private func createDetailMovieCellViewModel(review: Review) -> DetailMovieCellViewModel {
        DetailMovieCellViewModel(title: "", date: "", overview: "", posterUrl: "", name: review.author ?? "unknown", review: review.content, type: .review)
    }

    func getCellViewModel(at indexPath: IndexPath) -> DetailMovieCellViewModel {
        cellViewModels[indexPath.row]
    }


}

enum DetailCellType {
    case movie, review, sparator
}

struct DetailMovieCellViewModel {
    let title, date, overview, posterUrl, name, review: String
    let type: DetailCellType
}
