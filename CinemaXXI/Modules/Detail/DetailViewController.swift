//
//  DetailViewController.swift
//  CinemaXXI
//
//  Created by Giri Bahari on 20/01/22.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    lazy var viewModel: DetailViewModel = {
        DetailViewModel(api: DetailApiService())
    }()

    var movieId: Int?
    var movieTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(closeDetail))

        guard let movieTitle = movieTitle else { return }
        title =  movieTitle

        tableView.register(DetailMovieTableViewCell.nib, forCellReuseIdentifier: DetailMovieTableViewCell.identifier)
        tableView.register(ReviewTableViewCell.nib, forCellReuseIdentifier: ReviewTableViewCell.identifier)

        setUpViewModel()
    }

    func setUpViewModel() {
        viewModel.showAlert = { [weak self] in
            if let message = self?.viewModel.alertMessage {
                self?.showAlert(title: "Info", message: message)
            }
        }
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
        guard let movieId = movieId else { return }

        viewModel.fetchDetailMovie(id: movieId)
    }

    @objc
    private func closeDetail() {
        dismiss(animated: true)
    }

}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = viewModel.getCellViewModel(at: indexPath)

        switch data.type {
        case .movie:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailMovieTableViewCell.identifier) as? DetailMovieTableViewCell else {
                fatalError("DetailMovieTableViewCell not found")
            }
            cell.detailMovieCellViewModel = data
            cell.favoriteClosure = {
                self.viewModel.favoriteMovieAction(at: indexPath)
            }
            return cell
        case .sparator:
            let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "SparatorCell")
            cell.textLabel?.text = data.title
            return cell
        case .review:
            guard let reviewCell = tableView.dequeueReusableCell(withIdentifier: ReviewTableViewCell.identifier) as? ReviewTableViewCell else {
                fatalError("ReviewTableViewCell not found")
            }
            reviewCell.detailMovieCellViewModel = data
            return reviewCell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = viewModel.getCellViewModel(at: indexPath)

        switch data.type {
        case .movie:
            return 280.0
        case .sparator:
            return 50.0
        case .review:
            return UITableView.automaticDimension
        }
    }
}
