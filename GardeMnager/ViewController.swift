//
//  ViewController.swift
//  GardeMnager
//
//  Created by Grunt on 16/11/2016.
//  Copyright © 2016 Grunt. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var tableView: UITableView!
    var ingredients: [Ingredient] = []
    var recipes: [Recipe] = []
    var context: NSManagedObjectContext?
    var picker: UIPickerView?
    
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
            let eggs = Ingredient(context: self.context!)
            eggs.name = "Oeufs"
            eggs.quantity = 1
            let tomatoes = Ingredient(context: self.context!)
            tomatoes.name = "Tomates"
            tomatoes.quantity = 1
            let lasagnes = Recipe(context: context)
            lasagnes.name = "Lasagnes"
            lasagnes.addToIngredients(eggs)
            lasagnes.addToIngredients(tomatoes)
            
            eggs.quantity = 2
            tomatoes.quantity = 2
            let lasagnes2 = Recipe(context: context)
            lasagnes2.name = "Lasagnes2"
            lasagnes2.addToIngredients(eggs)
            lasagnes2.addToIngredients(tomatoes)
            
            let eggs2 = Ingredient(context: self.context!)
            eggs2.name = "Oeufs"
            eggs2.quantity = 20
            let tomatoes2 = Ingredient(context: self.context!)
            tomatoes2.name = "Tomates"
            tomatoes2.quantity = 20

            let lasagnes3 = Recipe(context: context)
            lasagnes3.name = "Lasagnes3"
            lasagnes3.addToIngredients(eggs2)
            lasagnes3.addToIngredients(tomatoes2)
            
            //print(lasagnes.ingredients?.allObjects)
            
            recipes.append(contentsOf: [lasagnes, lasagnes2, lasagnes3])
            
            
        }
        
        let tableView = UITableView(frame: view.bounds)
        view.addSubview(tableView)
        self.tableView = tableView
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let pickerFrame = CGRect(x: 0, y: 50, width: 270, height: 100)
        picker = UIPickerView(frame: pickerFrame)
        
        picker?.delegate = self
        picker?.dataSource = self
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        let edit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
        navigationItem.rightBarButtonItems = [edit, add]
        
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
        
        alert.addTextField { (imageUrlTextField) in
            imageUrlTextField.text = ""
            imageUrlTextField.placeholder = "URL de l'image"
            imageUrlTextField.keyboardType = UIKeyboardType.URL
        }
        
        alert.addTextField { (TextField) in
            TextField.text = ""
            TextField.placeholder = "URL de l'image"
            TextField.keyboardType = UIKeyboardType.URL
            TextField.addTarget(self, action: imagePickerControlle, for: UIControlEvents.touchDown)
        }

        
        let btn = UIButton()
        btn.setTitle("PICK", for: .normal)
        btn.frame = CGRect(x: 100, y: 0, width: 200, height: 100)
        alert.view.addSubview(btn)
        
//        let pickerFrame = CGRect(x: 0, y: 50, width: 270, height: 100)
//        
//        let pickPicture : UIButton = UIButton(frame: pickerFrame)
//        
//        alert.view.addSubview(pickPicture)
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            let ingredientField = alert.textFields![0] // Force unwrapping because we know it exists.
            let quantityField = alert.textFields![1]
            let imageUrlField = alert.textFields![2]
            //print("Text field: \(textField.text)")
            if (self.context != nil) {
                let index = self.findIngredientIndex(name: ingredientField.text!)
                if (index == -1) {
                    let ingredient = Ingredient(context: self.context!)
                    ingredient.name = ingredientField.text
                    ingredient.quantity = Int32((quantityField.text! as NSString).integerValue)
                    ingredient.imageUrl = imageUrlField.text
                    self.ingredients.append(ingredient)
                } else {
                    self.ingredients[index].quantity += Int32((quantityField.text! as NSString).integerValue)
                }
                self.tableView.reloadData()
                try! self.context?.save()
            }
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func test
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            //self.imageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
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
    
    func editTapped() {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Retirer les recettes vendues", message: "Recette et quantité", preferredStyle: .alert)
        
        // TODO : Creer liste déroulante
        
        
        alert.view.addSubview(picker!)
        
        
        alert.addTextField { (quantityTextField) in
            quantityTextField.text = "1"
            quantityTextField.placeholder = "Quantité"
            quantityTextField.keyboardType = UIKeyboardType.numberPad
        }
        
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            //            let recipeChoice = alert.selectionList![0] // Force unwrapping because we know it exists.
            
            
            
            
            //let quantityField = alert.textFields![1]
            
            //print("Text field: \(textField.text)")
            //            if (self.context != nil) {
            //                if ( self.checkIngredientsForRecipe(name: picker.getChoice(), quantity: quantityField) != -1) {
            //                    for ingr in recipe.ingrs {
            //                        for i in 0 ..< ingredients.count {
            //                            if (ingredients[i].name == ingr.name) {
            //                                ingredients[i].quantity -= ingr.quantity*quantity
            //                            }
            //                        }
            //                        return 0
            //                    }
            //                }
            //                self.tableView.reloadData()
            //                try! self.context?.save()
            //            }
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
    
    //    func checkIngredientsForRecipe(name: String, quantity: int) -> Int {
    //        for ingr in recipe.ingrs {
    //            for i in 0 ..< ingredients.count {
    //                if (ingredients[i].name == ingr.name && ingredients[i].quantity < ingr.quantity*quantity) {
    //                    return -1
    //                }
    //            }
    //            return 0
    //        }
    //    }
    
    
    
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int{
        return recipes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return recipes[row].name
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
        if ingredient.imageUrl != nil {
            let url = URL.init(string: ingredient.imageUrl!)
            if ingredient.imageUrl?.characters.count != 0 && url != nil {
                if let data = try? Data.init(contentsOf: url!) {
                    cell.imageView?.image = UIImage(data: data as Data)
                }
            } else if let url = URL.init(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/Question_mark_alternate.svg/langfr-90px-Question_mark_alternate.svg.png") {
                if let data = try? Data.init(contentsOf: url) {
                    cell.imageView?.image = UIImage(data: data as Data)
                }
            }
        } else if let url = URL.init(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/Question_mark_alternate.svg/langfr-90px-Question_mark_alternate.svg.png") {
            if let data = try? Data.init(contentsOf: url) {
                cell.imageView?.image = UIImage(data: data as Data)
            }
        }
        
            cell.textLabel?.text = ingredient.name
            cell.detailTextLabel?.text = String(format: "Quantité : %d", ingredient.quantity)
            
            // Returning the cell
            return cell
        }
        
}

