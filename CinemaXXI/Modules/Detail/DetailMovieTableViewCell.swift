//
//  DetailMovieTableViewCell.swift
//  CinemaXXI
//
//  Created by Giri Bahari on 20/01/22.
//

import UIKit

protocol DetailMovieTableViewCellProtocol {
    var id: Int {get set}
    var title: String {get set}
    var releaseDate: String {get set}
    var overview: String {get set}
    var posterUrl: String {get set}
    var posterData: Data {get set}
    var type: DetailCellType {get set}
    var state: FavoriteState {get set}
    var name: String {get set}
    var review: String {get set}
}

class DetailMovieTableViewCell: UITableViewCell {
    @IBOutlet weak var imgMovie: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnFavorite: UIButton!
    @IBAction func FavoriteAction(_ sender: UIButton) { favoriteClosure?() }

    var detailMovieCellViewModel: DetailMovieTableViewCellProtocol? {
        didSet {
            lblTitle.text = detailMovieCellViewModel?.title
            lblSubtitle.text = detailMovieCellViewModel?.releaseDate
            lblDescription.text = detailMovieCellViewModel?.overview
            if detailMovieCellViewModel!.posterUrl == "" {
                imgMovie.image = UIImage(data: (detailMovieCellViewModel!.posterData))
            } else {
                imgMovie.loadThumbnail(urlString: detailMovieCellViewModel!.posterUrl)
            }
            
            switch detailMovieCellViewModel?.state {
            case .unfavorite:
                btnFavorite.setImage(UIImage(systemName: "heart")?.withTintColor(.red, renderingMode: .alwaysOriginal), for: .normal)
            case .favorite:
                btnFavorite.setImage(UIImage(systemName: "heart.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal), for: .normal)
            case .none:
                break
            }
        }
    }

    var favoriteClosure: (() -> Void)?
}
