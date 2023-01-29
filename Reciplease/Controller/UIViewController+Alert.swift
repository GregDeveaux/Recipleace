//
//  ViewController.swift
//  Reciplease
//
//  Created by Greg Deveaux on 25/12/2022.
//

import UIKit

extension UIViewController {

        // -------------------------------------------------------
        // MARK: - alert
        // -------------------------------------------------------

    func presentAlert(with error: String) {
        let alert: UIAlertController = UIAlertController(title: "Erreur", message: error, preferredStyle: .alert)
        let action: UIAlertAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        present(alert, animated: true)
    }


}
