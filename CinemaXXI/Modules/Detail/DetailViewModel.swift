//
//  DetailViewModel.swift
//  CinemaXXI
//
//  Created by Giri Bahari on 20/01/22.
//

import Foundation

class DetailViewModel {
    private var api: DetailApiServiceProtocol
    private var tempCellViewModel = [DetailMovieCellViewModel]()
    private lazy var favoriteProvider = {
        return FavoriteProvider()
    }()
    private var cellViewModels: [DetailMovieCellViewModel] = [DetailMovieCellViewModel]() {
        didSet {
            reloadTableView?()
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
                self?.processDetailMovie(movie: detailMovie)
                self?.fetchReview(id: id, page: 1)
            }
        }
    }
    
    private func fetchReview(id: Int, page: Int) {
        api.fetchReview(id: id, page: page) { [weak self] status, reviews, error in
            self?.isLoading = false
            if let error = error {
                self?.alertMessage = error.rawValue
            } else {
                self?.processReview(reviews: reviews)
            }
        }
    }
    
    private func processDetailMovie(movie: Movie) {
        var favoriteState: FavoriteState = .unfavorite
        favoriteProvider.getFavoriteMovie(movie.title) { favoriteMovie in
            DispatchQueue.main.async {
                if favoriteMovie != nil {
                    favoriteState = .favorite
                }
                self.tempCellViewModel.append(DetailMovieCellViewModel(id: movie.id,title: movie.title, releaseDate: movie.releaseDate, overview: movie.overview, posterUrl: "https://image.tmdb.org/t/p/w185\(movie.posterPath)", posterData: Data(), type: .movie, state: favoriteState, name: "", review: ""))
                self.tempCellViewModel.append(DetailMovieCellViewModel(id: 0, title: "Review", releaseDate: "", overview: "", posterUrl: "", posterData: Data(), type: .sparator, state: .unfavorite, name: "", review: ""))
            }
        }
    }
    
    private func processReview(reviews: [Review]) {
        for review in reviews {
            tempCellViewModel.append(createReviewMovieCellViewModel(review: review))
        }
        self.cellViewModels = tempCellViewModel
    }
    
    private func createReviewMovieCellViewModel(review: Review) -> DetailMovieCellViewModel {
        DetailMovieCellViewModel(id: 0, title: "", releaseDate: "", overview: "", posterUrl: "", posterData: Data(), type: .review, state: .unfavorite, name: review.author!, review: review.content)
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> DetailMovieCellViewModel {
        cellViewModels[indexPath.row]
    }
    
    func favoriteMovieAction(at indexPath: IndexPath) {
        let movie = getCellViewModel(at: indexPath)
        switch movie.state {
        case .favorite:
            // Delete Favorite
            favoriteProvider.deleteFavoriteMovie(Int64(movie.id)) { [weak self] status in
                self?.cellViewModels[indexPath.row].state = .unfavorite
            }
        case .unfavorite:
            // Add favorite
            var posterData = Data()
            Service.shared.downloadImage(url: URL(string: movie.posterUrl)!) { [weak self] data, error in
                DispatchQueue.main.async {
                    if error == nil, data != nil {
                        posterData = data!
                    }
                    let favorite = Favorite(id: Int64(movie.id), poster: posterData, title: movie.title, overview: movie.overview, releaseDate: movie.releaseDate, posterUrl: movie.posterUrl)
                    self?.favoriteProvider.createFavorite(favorite) { [weak self] status in
                        self?.cellViewModels[indexPath.row].state = .favorite
                    }
                }
            }
        }
    }
}

enum DetailCellType {
    case movie, review, sparator
}

enum FavoriteState {
    case favorite, unfavorite
}

struct DetailMovieCellViewModel: DetailMovieTableViewCellProtocol {
    var id: Int
    var title: String
    var releaseDate: String
    var overview: String
    var posterUrl: String
    var posterData: Data
    var type: DetailCellType
    var state: FavoriteState
    var name: String
    var review: String
}
