//
//  ViewController.swift
//  GardeMnager
//
//  Created by Grunt on 16/11/2016.
//  Copyright © 2016 Grunt. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    weak var tableView: UITableView!
    var ingredients: [Ingredient] = []
    var context: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let context = DataManager.shared.objectContext {
            
            self.context = context
            let request: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
            if let ingredientsBDD = try? context.fetch(request) {
                ingredients.append(contentsOf: ingredientsBDD)
            }
            print("#######")
            print(ingredients.count)
            print("#######")
//            let tomatoes = Ingredient(context: context)
//            tomatoes.name = "Tomates"
//            tomatoes.quantity = 5
//            let eggs = Ingredient(context: context)
//            eggs.name = "Oeufs"
//            eggs.quantity = 18
//            ingredients.append(tomatoes)
//            ingredients.append(eggs)
        }
        
        let tableView = UITableView(frame: view.bounds)
        view.addSubview(tableView)
        self.tableView = tableView
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItems = [add]
        
        self.title = "Garde Manger"
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addTapped() {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Ajouter un ingédient en stock", message: "Ingrédient et quantité", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (ingredientTextField) in
            ingredientTextField.text = ""
            ingredientTextField.placeholder = "Ingrédient"
        }
        
        alert.addTextField { (quantityTextField) in
            quantityTextField.text = ""
            quantityTextField.placeholder = "Quantité"
            quantityTextField.keyboardType = UIKeyboardType.numberPad
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            let ingredientField = alert.textFields![0] // Force unwrapping because we know it exists.
            let quantityField = alert.textFields![1]
            //print("Text field: \(textField.text)")
            if (self.context != nil) {
                let index = self.findIngredientIndex(name: ingredientField.text!)
                if (index == -1) {
                    let ingredient = Ingredient(context: self.context!)
                    ingredient.name = ingredientField.text
                    ingredient.quantity = Int32((quantityField.text! as NSString).integerValue)
                    self.ingredients.append(ingredient)
                } else {
                    self.ingredients[index].quantity += Int32((quantityField.text! as NSString).integerValue)
                }
                self.tableView.reloadData()
                try! self.context?.save()
            }
            print("start")
            /*if let context = DataManager.shared.objectContext {
                let request: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
                if let ingredients = try? context.fetch(request) {
                    for i in ingredients {
                        print(i.name!)
                    }
                }
            }*/
            print("end")
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
    * This method returns the index of the ingredient of a defined name, otherwise -1
    * @param The name of the ingredient to search
    * @return The index or -1
    */
    func findIngredientIndex(name: String) -> Int {
        for i in 0 ..< ingredients.count {
            if (ingredients[i].name == name) {
                return i
            }
        }
        return -1
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.context?.delete(ingredients[indexPath.row])
            ingredients.remove(at: indexPath.row)
            
            do {
                try self.context?.save()
            } catch let error as NSError {
                print("Error While Deleting Note: \(error.userInfo)")
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            //try! self.context?.save()
            //TODO save if because the previous line doesn't not save the deletion
        }
    }

    


}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Getting the right element
        let ingredient = ingredients[indexPath.row]
        
        // Instantiate a cell or reuse one if possible
        let cellIdentifier = "ElementCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        // Adding the right informations
        cell.textLabel?.text = ingredient.name
        cell.detailTextLabel?.text = String(format: "Quantité : %d", ingredient.quantity)
        
        // Returning the cell
        return cell
    }
    
}

