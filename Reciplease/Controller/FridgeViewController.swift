//
//  ViewController.swift
//  Reciplease
//
//  Created by Greg-Mini on 23/12/2022.
//

import UIKit
import Firebase

class FridgeViewController: UIViewController {

        // -------------------------------------------------------
        //MARK: properties
        // -------------------------------------------------------

    var listOfStuffsFromFridge: [String] = ["orange", "lemon"]
    private var sendTheIngredient = false {
        didSet {
            searchRecipes.setNeedsUpdateConfiguration()
        }
    }

        // -------------------------------------------------------
        //MARK: outlet
        // -------------------------------------------------------

    @IBOutlet weak var stuffsFromFridgeTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var searchRecipes: UIButton!
    @IBOutlet weak var listOfStuffsFromFridgeTableView: UITableView!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var whiteBoardView: UIView! {
        didSet {
            whiteBoardView.layer.cornerRadius = 5
        }
    }

        // -------------------------------------------------------
        //MARK: cycle of view
        // -------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
    }

        // -------------------------------------------------------
        //MARK: actions
        // -------------------------------------------------------

    @IBAction func tappedAddStuffsFromFridge(_ sender: Any) {
        addStuffFromFridgeInTheList()
    }

    private func addStuffFromFridgeInTheList() {
            // Check if there a stuff of fridge writted
        guard let newStuff = stuffsFromFridgeTextField.text, !newStuff.isEmpty else {
                // if the textField is empty give the user alert
            return presentAlert(with: "Please enter the stuff \n before tapped Add button, \n thank you 😃")
        }

            // add a new stuff of fridge in the array of the list
        listOfStuffsFromFridge.append(newStuff)

            // adapt the tableView with the new stuff
        let row = listOfStuffsFromFridge.count - 1
        let indexPath = IndexPath(row: row, section: 0)

        listOfStuffsFromFridgeTableView.beginUpdates()
        listOfStuffsFromFridgeTableView.insertRows(at: [indexPath], with: .top)
        listOfStuffsFromFridgeTableView.endUpdates()

            // reveal the inside of the tableView in debug
        print("✅ FRIDGE_VC/ADD: stuff added: \(newStuff)")
        dump(listOfStuffsFromFridge)

            // reinit a add stuffsFromFridgeTextField empty for new stuff
        stuffsFromFridgeTextField.text = ""
        view.endEditing(true)
    }

    @IBAction func tappedClearAllStuffsFromFridge(_ sender: Any) {
            // delete the whole stuffs of the list
        listOfStuffsFromFridge.removeAll()
        print("✅ FRIDGE_VC/CLEAR: all stuffs deleted: \(listOfStuffsFromFridge)")
            // delete the whole stuffs of the tableView
        listOfStuffsFromFridgeTableView.reloadData()
    }

    @IBAction func tappedSearchRecipes(_ sender: Any) {
            // send stuff to recover the possible recipes
        self.performSegue(withIdentifier: "SegueListOfRecipe", sender: listOfStuffsFromFridge)
    }

        // Send the information to RecipesTableViewController which will use the API.Edamam
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueListOfRecipe" {
            let destinationController = segue.destination as? RecipesTableViewController
            destinationController?.listOfStuffsFromFridge = listOfStuffsFromFridge
            print("✅ FRIDGE_VC/SEGUE: \(String(describing: destinationController?.listOfStuffsFromFridge))")
        }
    }

    @IBAction func tappedSignOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            print("✅ User is sign out")
            dismiss(animated: true)
        } catch {
            print("🛑 SignOut impossible")
        }
    }

}


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

