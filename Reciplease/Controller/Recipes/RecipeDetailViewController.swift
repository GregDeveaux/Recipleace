//
//  RecipeDetailViewController.swift
//  Reciplease
//
//  Created by Greg-Mini on 23/12/2022.
//

import UIKit

class RecipeDetailViewController: UIViewController {

        //MARK: - outlets

    @IBOutlet weak var recipeDetailTableView: UITableView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeTitleLabel: UILabel! {
        didSet {
            recipeTitleLabel.numberOfLines = 0
        }
    }
    @IBOutlet weak var mealType: UILabel! {
        didSet {
            mealType.layer.cornerRadius = 2.5
            mealType.layer.masksToBounds = true
        }
    }


        //MARK: - view did load

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        recipeDetailTableView.delegate = self
        recipeDetailTableView.dataSource = self
    }

    func setupNavigationBar() {
            // Create a tranparency navigationBar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
            // font navigationBar is white
        navigationController?.navigationBar.tintColor = .white
            // The image pass behind navigationBar and touch the top
        recipeDetailTableView.contentInsetAdjustmentBehavior = .never
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

extension RecipeDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "RecipeDetailTableViewCell"

        switch indexPath.row {
            case 0:
                let cell = recipeDetailTableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RecipeDetailTableViewCell
                cell.ingredientsLabel.text = "Ingredients"
                return cell

            case 1:
                let cell = recipeDetailTableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RecipeDetailTableViewCell
                cell.ingredientsLabel.text = "Ingredients"
                return cell

            default:
                fatalError("")
        }
    }


}
