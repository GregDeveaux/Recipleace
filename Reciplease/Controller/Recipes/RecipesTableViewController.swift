//
//  RecipesTableViewController.swift
//  Reciplease
//
//  Created by Greg-Mini on 26/12/2022.
//

import UIKit

class RecipesTableViewController: UITableViewController {

        //MARK: properties
    var listOfRecipes: [Recipe] = [Recipe(title: "Citrus Glaze recipes",
                                          image: "Pizza",
                                          ingredients: [Ingredient(foodCategory: "sugars",
                                                                   image: "https://www.edamam.com/food-img/290/290624aa4c0e279551e462443e38bb40.jpg",
                                                                   weight: 150.0,
                                                                   food: "confectioners\' sugar"),
                                                        Ingredient(foodCategory: "fruit",
                                                                   image: "https://www.edamam.com/food-img/8ea/8ea264a802d6e643c1a340a77863c6ef.jpg",
                                                                   weight: 0.937500000047551,
                                                                   food: "orange")],
                                          durationInMinutes: 15,
                                          note: 5),
                                   Recipe(title: "Pizza",
                                          image: "Pizza",
                                          ingredients: [Ingredient(foodCategory: "sugars",
                                                                   image: "https://www.edamam.com/food-img/290/290624aa4c0e279551e462443e38bb40.jpg",
                                                                   weight: 150.0,
                                                                   food: "confectioners\' sugar"),
                                                        Ingredient(foodCategory: "fruit",
                                                                   image: "https://www.edamam.com/food-img/8ea/8ea264a802d6e643c1a340a77863c6ef.jpg",
                                                                   weight: 0.937500000047551,
                                                                   food: "orange")],
                                          durationInMinutes: 15,
                                          note: 5)]

        //MARK: outlets
    @IBOutlet var listOfRecipesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(listOfRecipes)
        listOfRecipesTableView.delegate = self
        listOfRecipesTableView.dataSource = self
    }

        // MARK: table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listOfRecipes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "RecipeCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RecipesTableViewCell

        cell.titleLabel.text = listOfRecipes[indexPath.row].title
        listOfRecipes[indexPath.row].ingredients.forEach({ ingredient in
            cell.ingredientsLabel.text = ingredient.food
        })
        cell.recipeImage.image = UIImage(named: listOfRecipes[indexPath.row].image) 

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
