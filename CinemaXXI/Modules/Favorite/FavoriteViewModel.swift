//
//  FavoriteViewModel.swift
//  CinemaXXI
//
//  Created by Giri Bahari on 21/01/22.
//

import Foundation

class FavoriteViewModel {

    var favoriteProvider: FavoriteProvider

    private var cellViewModels: [FavoriteCellViewModel] = [FavoriteCellViewModel]() {
        didSet {
            self.reloadTableView?()
        }
    }
    var isLoading: Bool = false {
        didSet {
            updateLoadingStatus?()
        }
    }
    var numberOfCells: Int {
        return cellViewModels.count
    }

    var reloadTableView: (() -> Void)?
    var showAlert: (() -> Void)?
    var updateLoadingStatus: (() -> Void)?

    init(favoriteProvider: FavoriteProvider = FavoriteProvider()) {
        self.favoriteProvider = favoriteProvider
    }

    func getFavoriteMovies() {
        isLoading = true
        favoriteProvider.getFavoriteMovies { favoriteMovies in
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.processFavoriteCellViewModel(favoriteMovies)
            }
        }
    }

    func getCellViewModel(at indexPath: IndexPath) -> FavoriteCellViewModel {
        cellViewModels[indexPath.row]
    }

    private func processFavoriteCellViewModel(_ favorites: [Favorite]) {
        var favCells = [FavoriteCellViewModel]()
        for favorite in favorites {
            favCells.append(FavoriteCellViewModel(id: Int(favorite.id!), title: favorite.title!, releaseDate: favorite.releaseDate!, overview: favorite.overview!, posterUrl: favorite.posterUrl!, posterData: favorite.poster!))
        }
        cellViewModels = favCells
    }

}

struct FavoriteCellViewModel: TmdbTableViewCellProtocol {
    var id: Int
    var title: String
    var releaseDate: String
    var overview: String
    var posterUrl: String
    var posterData: Data
}
