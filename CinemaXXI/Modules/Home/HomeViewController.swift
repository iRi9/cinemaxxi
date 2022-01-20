//
//  ViewController.swift
//  CinemaXXI
//
//  Created by Giri Bahari on 19/01/22.
//

import UIKit

class HomeViewController: UIViewController, CategoryProtocol {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnCategory: UIButton!

    lazy var viewModel: HomeViewModel = {
        HomeViewModel(api: HomeApiService())
    }()

    private var selectedCategory = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "TMDB"

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart")?.withTintColor(.red, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(favoriteAction))

        btnCategory.setTitle("Category: \(MovieCategory(rawValue: selectedCategory)?.display ?? "-")", for: .normal)

        tableView.register(TmdbTableViewCell.nib, forCellReuseIdentifier: TmdbTableViewCell.identifier)
        setUpViewModel()
    }

    func setUpViewModel() {
        viewModel.showAlert = { [weak self] in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.showAlert(title: "Info", message: message)
                }
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

        viewModel.fetchMovie(category: MovieCategory.nowplaying.path, page: 1)
    }

    @IBAction func CategoryAction(_ sender: UIButton) {
        let categoryViewController = CategoryViewController()
        categoryViewController.delegate = self
        categoryViewController.selectedCategory = selectedCategory
        let navigationController = UINavigationController(rootViewController: categoryViewController)
        present(navigationController, animated: true)
    }

    @objc func favoriteAction() {
        // TODO: go to favorite page
    }

    func didSelectCategory(category: Int) {
        selectedCategory = category
        btnCategory.setTitle("Category: \(MovieCategory(rawValue: selectedCategory)?.display ?? "-")", for: .normal)
        viewModel.fetchMovie(category: MovieCategory(rawValue: selectedCategory)!.path, page: 1)
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCells
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TmdbTableViewCell.identifier) as? TmdbTableViewCell else {
            fatalError("TmdbTableViewCell not found")
        }
        cell.tmdbViewModel = viewModel.getCellViewModel(at: indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = DetailViewController(nibName: "DetailViewController", bundle: nil)
        detailViewController.movieId = viewModel.getCellViewModel(at: indexPath).id
        detailViewController.movieTitle = viewModel.getCellViewModel(at: indexPath).title
        let navigationController = UINavigationController(rootViewController: detailViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}

extension UITableView {
    func setEmptyView(message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let lblMessage = UILabel()
        lblMessage.translatesAutoresizingMaskIntoConstraints = false
        lblMessage.text = message
        lblMessage.numberOfLines = 0
        lblMessage.textAlignment = .center

        emptyView.addSubview(lblMessage)

        lblMessage.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        lblMessage.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true

        self.backgroundView = emptyView
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

protocol CategoryProtocol {
    func didSelectCategory(category: Int)
}

// MARK: - Category View Controller
class CategoryViewController: UITableViewController {

    var delegate: CategoryProtocol?
    var selectedCategory: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Category"
        self.tableView.allowsMultipleSelection = false
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MovieCategory.allCases.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "Cell")
        cell.textLabel?.text = MovieCategory(rawValue: indexPath.row)?.display

        if selectedCategory != nil, selectedCategory == indexPath.row {
            cell.accessoryType = .checkmark
        }

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.delegate != nil {
            delegate?.didSelectCategory(category: indexPath.row)
            dismiss(animated: true)
        }
    }
}

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(action)

        present(alertController, animated: true)
    }
}
