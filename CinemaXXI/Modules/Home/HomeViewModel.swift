//
//  HomeViewModel.swift
//  CinemaXXI
//
//  Created by Giri Bahari on 19/01/22.
//

import Foundation

class HomeViewModel {
    var api: HomeApiServiceProtocol
    private var cellViewModels: [MovieCellViewModel] = [MovieCellViewModel]() {
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

    init(api: HomeApiServiceProtocol = HomeApiService()) {
        self.api = api
    }

    func fetchMovie(category: String, page: Int) {
        isLoading = true
        api.fetchMovie(category: category, page: page) { [weak self] status, movies, error in
            self?.isLoading = false
            if let error = error {
                self?.alertMessage = error.rawValue
            } else {
                self?.processMoviesViewModel(movies)
            }
        }
    }

    func getCellViewModel(at indexPath: IndexPath) -> MovieCellViewModel {
        cellViewModels[indexPath.row]
    }

    private func processMoviesViewModel(_ movies: [Movie]) {
        var tempCellViewModels = [MovieCellViewModel]()
        for movie in movies {
            tempCellViewModels.append(createMovieCellViewModel(movie: movie))
        }
        self.cellViewModels = tempCellViewModels
    }

    private func createMovieCellViewModel(movie: Movie) -> MovieCellViewModel {
        MovieCellViewModel(id: movie.id,title: movie.title, releaseDate: movie.releaseDate, overview: movie.overview, posterUrl: "https://image.tmdb.org/t/p/w185\(movie.posterPath)", posterData: Data())
    }

}

enum MovieCellDownloadState {
    case new, downloaded, failed
}

struct MovieCellViewModel: TmdbTableViewCellProtocol {
    var id: Int
    var title: String
    var releaseDate: String
    var overview: String
    var posterUrl: String
    var posterData: Data
}
