//
//  TmdbTableViewCell.swift
//  CinemaXXI
//
//  Created by Giri Bahari on 19/01/22.
//

import UIKit

protocol TmdbTableViewCellProtocol {
    var id: Int {get set}
    var title: String {get set}
    var releaseDate: String {get set}
    var overview: String {get set}
    var posterUrl: String {get set}
    var posterData: Data {get set}
}

class TmdbTableViewCell: UITableViewCell {
    @IBOutlet weak var imgMovie: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!

    var tmdbViewModel: TmdbTableViewCellProtocol? {
        didSet {
            lblTitle.text = tmdbViewModel?.title
            lblSubtitle.text = tmdbViewModel?.releaseDate
            lblDescription.text = tmdbViewModel?.overview
            imgMovie.loadThumbnail(urlString: tmdbViewModel!.posterUrl)
        }
    }
}

extension UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}
