//
//  FavoriteViewController.swift
//  CinemaXXI
//
//  Created by Giri Bahari on 19/01/22.
//

import UIKit

class FavoriteViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    lazy var viewModel: FavoriteViewModel = {
        FavoriteViewModel()
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Favorite Movie"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(closeFavorite))

        tableView.register(TmdbTableViewCell.nib, forCellReuseIdentifier: TmdbTableViewCell.identifier)
        setUpViewModel()

    }

    @objc
    private func closeFavorite() {
        dismiss(animated: true)
    }

    func setUpViewModel() {
        viewModel.updateLoadingStatus = { [weak self] in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.tableView.setEmptyView(message: "Loading...")
                } else {
                    self?.tableView.restore()
                }
            }
        }
        viewModel.reloadTableView = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        viewModel.getFavoriteMovies()
    }

}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.numberOfCells == 0 {
            tableView.setEmptyView(message: "No Data")
        }
        return viewModel.numberOfCells
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TmdbTableViewCell.identifier) as? TmdbTableViewCell else {
            fatalError("TmdbTableViewCell not found")
        }
        cell.tmdbViewModel = viewModel.getCellViewModel(at: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailFavorite = DetailFavoriteController()
        detailFavorite.favorite = viewModel.getCellViewModel(at: indexPath)
        detailFavorite.deleteClosure = { self.viewModel.getFavoriteMovies() }
        let navigationController = UINavigationController(rootViewController: detailFavorite)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
}

// MARK: - Detail favorite controller
class DetailFavoriteController: UITableViewController {

    private var detailMovieCellViewModel: DetailMovieTableViewCellProtocol?
    private lazy var favoriteProvider = {
        return FavoriteProvider()
    }()

    var favorite: TmdbTableViewCellProtocol?

    var deleteClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let fav = favorite {
            title = fav.title
            detailMovieCellViewModel = processFavorite(fav)
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(closeDetail))

        tableView.register(DetailMovieTableViewCell.nib, forCellReuseIdentifier: DetailMovieTableViewCell.identifier)
        
    }
    private func processFavorite(_ favorite: TmdbTableViewCellProtocol) -> DetailMovieTableViewCellProtocol {
        DetailMovieCellViewModel(id: Int(favorite.id), title: favorite.title, releaseDate: favorite.releaseDate, overview: favorite.overview, posterUrl: favorite.posterUrl, posterData: favorite.posterData, type: .movie, state: .favorite, name: "", review: "")
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailMovieTableViewCell.identifier) as? DetailMovieTableViewCell else {
            fatalError("DetailMovieTableViewCell is not faound")
        }
        cell.detailMovieCellViewModel = detailMovieCellViewModel
        cell.favoriteClosure = { [weak self] in
            self?.favoriteProvider.deleteFavoriteMovie(Int64((self?.detailMovieCellViewModel?.id)!)) { status in
                DispatchQueue.main.async {
                    self?.deleteClosure?()
                    self?.closeDetail()
                }
            }
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280.0
    }
    @objc
    private func closeDetail() {
        dismiss(animated: true)
    }
}
