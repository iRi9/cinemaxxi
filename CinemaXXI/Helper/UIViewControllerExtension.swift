//
//  UIViewControllerExtension.swift
//  CinemaXXI
//
//  Created by Giri Bahari on 22/01/22.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(action)

        present(alertController, animated: true)
    }
}
