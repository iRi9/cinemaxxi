//
//  DetailMovieTableViewCell.swift
//  CinemaXXI
//
//  Created by Giri Bahari on 20/01/22.
//

import UIKit

class DetailMovieTableViewCell: UITableViewCell {
    @IBOutlet weak var imgMovie: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnFavorite: UIButton!

    var detailMovieCellViewModel: DetailMovieCellViewModel? {
        didSet {
            lblTitle.text = detailMovieCellViewModel?.title
            lblSubtitle.text = detailMovieCellViewModel?.date
            lblDescription.text = detailMovieCellViewModel?.overview
            imgMovie.loadThumbnail(urlString: detailMovieCellViewModel!.posterUrl)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        btnFavorite.setImage(UIImage(systemName: "heart")?.withTintColor(.red, renderingMode: .alwaysOriginal), for: .normal)
    }
}
