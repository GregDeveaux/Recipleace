//
//  ViewController.swift
//  Reciplease
//
//  Created by Greg Deveaux on 23/12/2022.
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

    @IBOutlet weak var stuffsFromFridgeTextField: UITextField! {
        didSet {
            stuffsFromFridgeTextField.isAccessibilityElement = true
            stuffsFromFridgeTextField.accessibilityTraits = .staticText
            stuffsFromFridgeTextField.accessibilityHint = "Indicate the different stuffs from your fridge, please"
        }
    }
    @IBOutlet weak var addButton: UIButton! {
        didSet {
            /// info to accessibility with Voice Over
            IndicateAccessibilityOfTheButton(to: addButton, hint: "tapped here to add stuff in list")
        }
    }
    @IBOutlet weak var clearButton: UIButton! {
        didSet {
            IndicateAccessibilityOfTheButton(to: clearButton, hint: "tapped here to clear your all list")
        }
    }
    @IBOutlet weak var searchRecipes: UIButton! {
        didSet {
            IndicateAccessibilityOfTheButton(to: searchRecipes, hint: "tapped here to send your list and retrieve the various associated recipes")
        }
    }
    @IBOutlet weak var listOfStuffsFromFridgeTableView: UITableView!
    @IBOutlet weak var signOutButton: UIButton! {
        didSet {
            IndicateAccessibilityOfTheButton(to: signOutButton, hint: "tapped here to sign out App")
        }
    }
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

    func IndicateAccessibilityOfTheButton(to button: UIButton , hint: String ) {
        var myButton = button
        myButton.isAccessibilityElement = true
        myButton.accessibilityTraits = .button
        myButton.accessibilityHint = hint
    }
}
