//
//  ViewController.swift
//  Reciplease
//
//  Created by Greg-Mini on 23/12/2022.
//

import UIKit

class FridgeViewController: UIViewController {

    //MARK: - properties
    var listOfStuffsFromFridge: [String] = ["orange", "lemon"]

    //MARK: - IBOutlet
    @IBOutlet weak var addStuffsFromFridgeTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var searchRecipes: UIButton!
    
    @IBOutlet weak var listOfStuffsFromFridgeTableView: UITableView!
        //MARK: - view did load

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

        //MARK: - actions
    @IBAction func tappedAddStuffsFromFridge(_ sender: Any) {
        guard let newStuff = addStuffsFromFridgeTextField.text else { return }
        listOfStuffsFromFridge.append(newStuff)
    }

    @IBAction func tappedClearAllStuffsFromFridge(_ sender: Any) {
    }

    @IBAction func tappedSearchRecipes(_ sender: Any) {
    }

}

    //MARK: - list of stuffs from fridge TableView
extension FridgeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfStuffsFromFridge.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "StuffsFromFridge"
        let cell = listOfStuffsFromFridgeTableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        cell.textLabel?.text = "• \(listOfStuffsFromFridge[indexPath.row])"

        return cell
    }


}
