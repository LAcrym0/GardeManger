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
    var context: NSManagedObjectContext?
    var picker: UIPickerView?
    var ingredientName: String?
    var ingredientQuantity: Int32?
    var ingredientImageUrl: String?
    
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
            //lasagnes.addToIngredients(eggs)
            //lasagnes.addToIngredients(tomatoes)
            
            eggs.quantity = 2
            tomatoes.quantity = 2
            let lasagnes2 = Recipe(context: context)
            lasagnes2.name = "Lasagnes2"
            //lasagnes2.addToIngredients(eggs)
            //lasagnes2.addToIngredients(tomatoes)
            
            let eggs2 = Ingredient(context: self.context!)
            eggs2.name = "Oeufs"
            eggs2.quantity = 20
            let tomatoes2 = Ingredient(context: self.context!)
            tomatoes2.name = "Tomates"
            tomatoes2.quantity = 20
            
            let lasagnes3 = Recipe(context: context)
            lasagnes3.name = "Lasagnes3"
            //lasagnes3.addToIngredients(eggs2)
            //lasagnes3.addToIngredients(tomatoes2)
            
            //print(lasagnes.ingredients?.allObjects)
            
            //recipes.append(contentsOf: [lasagnes, lasagnes2, lasagnes3])
            
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
        definesPresentationContext = true
        
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
        
        /*alert.addTextField { (imageUrlTextField) in
         imageUrlTextField.text = ""
         imageUrlTextField.placeholder = "URL de l'image"
         imageUrlTextField.keyboardType = UIKeyboardType.URL
         }*/
        
        /*alert.addTextField { (imageUrlTextField) in
         imageUrlTextField.text = ""
         imageUrlTextField.placeholder = "URL de l'image"
         imageUrlTextField.keyboardType = UIKeyboardType.URL
         imageUrlTextField.addTarget(self, action: #selector(self.getImage(alertDial:))
         , for: UIControlEvents.allTouchEvents)
         }*/
        
        
        /* let btn = UIButton()
         btn.setTitle("PICK", for: .normal)
         btn.frame = CGRect(x: 100, y: 0, width: 200, height: 100)
         alert.view.addSubview(btn)*/
        
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
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
            
            let ingredient = Ingredient(context: self.context!)
            ingredient.name = ingredientName
            ingredient.imageUrl = url
            ingredient.quantity = ingredientQuantity!
            ingredients.append(ingredient)
            self.tableView.reloadData()
            
            //do { try! self.context?.save() }
            
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
    /*
     func getImage(alertDial: UIAlertController) {
     /*ingredientName = alert.textFields?[0].text
     ingredientQuantity = Int((alert.textFields?[1].text)!)
     if (alert.textFields?[2].text != nil) {
     ingredientImageUrl = alert.textFields?[2].text
     }*/
     print("Called")
     if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
     //we set the UIImagePickerController and its paremeters
     let pickerController = UIImagePickerController()
     pickerController.sourceType = .photoLibrary //source = galery
     pickerController.allowsEditing = false //after choosing the picture the user can't edit it
     pickerController.delegate = self
     pickerController.modalTransitionStyle = .crossDissolve
     
     //we show the pickerController
     alertDial.dismiss(animated: true, completion: {self.present(pickerController, animated: true, completion: nil)})
     
     }
     
     }*/
    
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

