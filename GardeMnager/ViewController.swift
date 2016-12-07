//
//  ViewController.swift
//  GardeMnager
//
//  Created by Grunt on 16/11/2016.
//  Copyright © 2016 Grunt. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var tableView: UITableView!
    var ingredients: [Ingredient] = []
    var recipes: [Recipe] = []
    var ingredientRecipes: [IngredientRecipe] = []
    var context: NSManagedObjectContext?
    var picker: UIPickerView?
    var ingredientName: String?
    var ingredientQuantity: Int32?
    var ingredientImageUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let context = DataManager.shared.objectContext {
            
            self.context = context
            let ingRequest: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
            if let ingredientsBDD = try? context.fetch(ingRequest) {
                ingredients.append(contentsOf: ingredientsBDD)
            }
            let recRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
            if let recipesBDD = try? context.fetch(recRequest) {
                recipes.append(contentsOf: recipesBDD)
            }
            let ingRecRequest: NSFetchRequest<IngredientRecipe> = IngredientRecipe.fetchRequest()
            if let ingredientRecipesBDD = try? context.fetch(ingRecRequest) {
                ingredientRecipes.append(contentsOf: ingredientRecipesBDD)
            }
            
            
            print("#######")
            print(ingredients.count)
            print("#######")
            
            if findRecipeIndex(name: "Lasagnes") == -1 {
                let lasagnes = Recipe(context: context)
                lasagnes.name = "Lasagnes"
                addIngredient(withName: "Oeufs", quantity: 2, toRecipe: lasagnes)
                addIngredient(withName: "Tomates", quantity: 4, toRecipe: lasagnes)
                addIngredient(withName: "Steaks", quantity: 5, toRecipe: lasagnes)
                recipes.append(lasagnes)
            }
            
            if findRecipeIndex(name: "Burger") == -1 {
                let burger = Recipe(context: context)
                burger.name = "Burger"
                addIngredient(withName: "Bacon", quantity: 2, toRecipe: burger)
                addIngredient(withName: "Pains", quantity: 2, toRecipe: burger)
                addIngredient(withName: "Steaks", quantity: 1, toRecipe: burger)
                addIngredient(withName: "Fromages", quantity: 2, toRecipe: burger)
                addIngredient(withName: "Tomates", quantity: 1, toRecipe: burger)
                recipes.append(burger)
            }
            
            if findRecipeIndex(name: "Tarte aux pommes") == -1 {
                let applePie = Recipe(context: context)
                applePie.name = "Tarte aux pommes"
                addIngredient(withName: "Sucre", quantity: 3, toRecipe: applePie)
                addIngredient(withName: "Pommes", quantity: 5, toRecipe: applePie)
                addIngredient(withName: "Pâte feuilletée", quantity: 1, toRecipe: applePie)
                addIngredient(withName: "Beurre", quantity: 2, toRecipe: applePie)
                recipes.append(applePie)
            }
            
            
        }
        
        let tableView = UITableView(frame: view.bounds)
        view.addSubview(tableView)
        self.tableView = tableView
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let pickerFrame = CGRect(x: 0, y: 150, width: 270, height: 70)
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
        
        
        
        // Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Ajouter l'image", style: .default, handler: { (_) in
            if alert.textFields![0].text?.characters.count != 0 {
                self.ingredientName = alert.textFields![0].text // Force unwrapping because we know it exists.
            } else {
                print("Can't create nameless ingredient")
                return;
            }
            if alert.textFields![1].text?.characters.count == 0 {
                self.ingredientQuantity = 0
            } else {
                self.ingredientQuantity = Int32(alert.textFields![1].text!)
            }
            // let imageUrlField = alert.textFields![2]
            //print("Text field: \(textField.text)")
            
            self.showImagePicker()
        }))
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .destructive, handler: nil))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func addIngredient(withName: String, quantity: Int, toRecipe: Recipe) {
        let index = findIngredientIndex(name: withName)
        var id: String
        if index == -1 {
            id = createNewIngredient(name: withName)
        } else {
            id = ingredients[index].objectID.uriRepresentation().absoluteString
        }
        print(withName + " " + id)
        if findIngredientRecipeIndex(idRecipe: toRecipe.objectID.uriRepresentation().absoluteString, idIngredient: id) == -1 {
            let ingredientRecipe = IngredientRecipe(context: self.context!)
            ingredientRecipe.idIngredient = id
            ingredientRecipe.idRecipe = toRecipe.objectID.uriRepresentation().absoluteString
            ingredientRecipe.quantity = Int32(quantity)
            try? self.context?.save()
            ingredientRecipes.append(ingredientRecipe)
        }
    }
    
    func createNewIngredient(name: String) -> String {
        let ingredient = Ingredient(context: self.context!)
        ingredient.quantity = 50
        ingredient.name = name
        try? self.context?.save()
        let id = ingredient.objectID.uriRepresentation().absoluteString
        ingredients.append(ingredient)
        return id
    }
    
    func showImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            //we set the UIImagePickerController and its paremeters
            let pickerController = UIImagePickerController()
            pickerController.sourceType = .photoLibrary //source = galery
            pickerController.allowsEditing = false //after choosing the picture the user can't edit it
            pickerController.delegate = self
            pickerController.modalTransitionStyle = .crossDissolve
            
            //we show the pickerController
            self.present(pickerController, animated: true, completion: nil)
            
        }
    }
    
    func save(url: String) {
        print (url)
        if (self.context != nil) {
            let index = findIngredientIndex(name: ingredientName!)
            if index == -1 {
                let ingredient = Ingredient(context: self.context!)
                ingredient.name = ingredientName
                ingredient.imageUrl = url
                ingredient.quantity = ingredientQuantity!
                ingredients.append(ingredient)
            } else {
                ingredients[index].quantity += Int32(ingredientQuantity!)
            }
            self.tableView.reloadData()
            
            do { try! self.context?.save() }
            
            ingredientName = ""
            ingredientQuantity = 0
            ingredientImageUrl = ""
            
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        let imageName = imageURL.lastPathComponent
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        let localPath = documentDirectory + imageName!
        let photoURL = NSURL(fileURLWithPath: localPath)
        picker.dismiss(animated: true, completion: nil)
        save(url: (photoURL.path)!)
    }
    
    func saveImageDocumentDirectory(ingredientName: String){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(ingredientName + ".jpg")
        let image = UIImage(named: ingredientName + ".jpg")
        print(paths)
        let imageData = UIImageJPEGRepresentation(image!, 0.5)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
    }
    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getImage(name: String) -> UIImage? {
        let fileManager = FileManager.default
        let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(".jpg")
        if fileManager.fileExists(atPath: imagePAth){
            return UIImage(contentsOfFile: imagePAth)!
        }else{
            return nil
        }
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
    
    func findRecipeIndex(name: String) -> Int {
        for i in 0 ..< recipes.count {
            if (recipes[i].name == name) {
                return i
            }
        }
        return -1
    }
    
    func findIngredientRecipeIndex(idRecipe: String, idIngredient: String) -> Int {
        for i in 0 ..< ingredientRecipes.count {
            if (ingredientRecipes[i].idRecipe == idRecipe && ingredientRecipes[i].idIngredient == idIngredient) {
                return i
            }
        }
        return -1
    }
    
    func editTapped() {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Retirer les recettes vendues", message: "Recette et quantité", preferredStyle: .alert)
        
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.35)
        alert.view.addConstraint(height);
        
        // TODO : Creer liste déroulante
        
        
        alert.view.addSubview(picker!)
        
        
        alert.addTextField { (quantityTextField) in
            quantityTextField.text = "1"
            quantityTextField.placeholder = "Quantité"
            quantityTextField.keyboardType = UIKeyboardType.numberPad
        }
        
        
        //Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            print("start")
            var error = true
            for ingredient in self.ingredients {//every ingredientRecipe
                print("Passage")
                let selectedRecipe = self.picker?.selectedRow(inComponent: 0)
                if selectedRecipe != -1 {
                    let idRecipe = self.recipes[selectedRecipe!].objectID.uriRepresentation().absoluteString //if this is an ingredient of the correct recipe
                    let ingredientRecipeIndex = self.findIngredientRecipeIndex(idRecipe: idRecipe, idIngredient: ingredient.objectID.uriRepresentation().absoluteString)
                    if (ingredientRecipeIndex != -1) {
                        if Int32(alert.textFields![0].text!)! < 0 {
                            break
                        }
                        ingredient.quantity -= self.ingredientRecipes[ingredientRecipeIndex].quantity * Int32(alert.textFields![0].text!)!  //decrement the quantity
                        if ingredient.quantity < 0 {
                            ingredient.quantity = 0
                        } else {
                            error = false
                        }
                        print("Found")
                    }
                }
            }
            if error == true {
                let alertError = UIAlertController(title: "Erreur", message: "Impossible, il manque des ingrédients", preferredStyle: .alert)
                alertError.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    alertError.dismiss(animated: true, completion: nil)
                }))
                alert.dismiss(animated: true, completion: nil)
                self.context?.undo()
                self.present(alertError, animated: true, completion: nil)
                
            } else {
                self.tableView.reloadData()
                alert.dismiss(animated: true, completion: nil)
            }
            try? self.context?.save()
            print("end")
        }))
        
        self.present(alert, animated: true, completion: nil)
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
            if FileManager.default.fileExists(atPath: ingredient.imageUrl!) {
                print("File exists")
            } else {
                print("File doesn't exist")
            }
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

