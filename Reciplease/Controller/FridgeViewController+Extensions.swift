//
//  FridgeViewController+Extensions.swift
//  Reciplease
//
//  Created by Greg Deveaux on 28/01/2023.
//

import UIKit

    // -------------------------------------------------------
    //MARK: - list of stuffs from fridge TableView
    // -------------------------------------------------------

extension FridgeViewController: UITableViewDataSource {
        // calculate the number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfStuffsFromFridge.count
    }
        // here create the different cells of the list
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "StuffsFromFridge"
        let cell = listOfStuffsFromFridgeTableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        cell.textLabel?.text = "• \(listOfStuffsFromFridge[indexPath.row])"

        return cell
    }
}

extension FridgeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                // delete the stuff of the list
            listOfStuffsFromFridge.remove(at: indexPath.row)
                // delete the stuff line of the tableView
            listOfStuffsFromFridgeTableView.beginUpdates()
            listOfStuffsFromFridgeTableView.deleteRows(at: [indexPath], with: .fade)
            listOfStuffsFromFridgeTableView.endUpdates()
        }
    }
}

    // -------------------------------------------------------
    // MARK: Keyboard setup dismiss
    // -------------------------------------------------------

extension FridgeViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        stuffsFromFridgeTextField.resignFirstResponder()
        return true
    }
}



