//
//  ReviewTableViewCell.swift
//  CinemaXXI
//
//  Created by Giri Bahari on 20/01/22.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblReview: UILabel!

    var detailMovieCellViewModel: DetailMovieCellViewModel? {
        didSet {
            lblName.text = detailMovieCellViewModel?.name
            lblReview.text = detailMovieCellViewModel?.review
        }
    }
}
