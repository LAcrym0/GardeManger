//
//  ViewController.swift
//  GardeMnager
//
//  Created by Grunt on 16/11/2016.
//  Copyright © 2016 Grunt. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage

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
                addIngredient(withName: "Oeufs", quantity: 2, url: "http://static.commentcamarche.net/sante-medecine.commentcamarche.net/faq/images/QqKAL9bu-oeufs.png",toRecipe: lasagnes)
                addIngredient(withName: "Tomates", quantity: 4, url: "https://c5.staticflickr.com/4/3043/2694720316_65101af7a1_o.jpg", toRecipe: lasagnes)
                addIngredient(withName: "Steaks", quantity: 5, url: "http://www.dangersalimentaires.com/wp-content/uploads/2012/10/steak-hache-congele.jpg", toRecipe: lasagnes)
                recipes.append(lasagnes)
            }
            
            if findRecipeIndex(name: "Burger") == -1 {
                let burger = Recipe(context: context)
                burger.name = "Burger"
                addIngredient(withName: "Bacon", quantity: 2, url: "http://barbuzz.net/images/bacon-bacon.jpg", toRecipe: burger)
                addIngredient(withName: "Pains", quantity: 2, url: "https://www.je-papote.com/wp-content/uploads/2014/02/pain-burger-maison.jpg", toRecipe: burger)
                addIngredient(withName: "Steaks", quantity: 1, url: "http://www.dangersalimentaires.com/wp-content/uploads/2012/10/steak-hache-congele.jpg", toRecipe: burger)
                addIngredient(withName: "Fromages", quantity: 2, url: "http://les-alpages.fr/wp-content/uploads/2014/09/cheddar-3.jpg", toRecipe: burger)
                addIngredient(withName: "Tomates", quantity: 1, url: "https://c5.staticflickr.com/4/3043/2694720316_65101af7a1_o.jpg", toRecipe: burger)
                recipes.append(burger)
            }
            
            if findRecipeIndex(name: "Tarte aux pommes") == -1 {
                let applePie = Recipe(context: context)
                applePie.name = "Tarte aux pommes"
                addIngredient(withName: "Sucre", quantity: 3, url: "http://media.rtl.fr/cache/VPaz3xCJinpFDHoQWoh51g/795v530-0/online/image/2015/0518/7778397968_sucre.jpg", toRecipe: applePie)
                addIngredient(withName: "Pommes", quantity: 5, url: "http://www.aromemarket.com/549/10-ml-arome-pomme-fa-stark-flavor-apple.jpg", toRecipe: applePie)
                addIngredient(withName: "Pâte feuilletée", quantity: 1, url: "http://img.cac.pmdstatic.net/fit/http.3A.2F.2Fwww.2Ecuisineactuelle.2Efr.2Fvar.2Fcui.2Fstorage.2Fimages.2Fvideos.2F1-technique-1-minute.2Fcomment-reussir-sa-pate-feuilletee.2F1847811-1-fre-FR.2Fcomment-reussir-sa-pate-feuilletee.2Ejpg/734x367/crop-from/center/comment-reussir-sa-pate-feuilletee.jpeg", toRecipe: applePie)
                addIngredient(withName: "Beurre", quantity: 2, url: "http://www.aliments.com/images/nb/beurre.jpg", toRecipe: applePie)
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
        Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.update), userInfo: nil, repeats: false);
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func update() {
        //to display images async
        self.tableView.reloadData()
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
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .destructive, handler: nil))
        
        // Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
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
            self.ingredientImageUrl = alert.textFields![2].text?.characters.count == 0 ? "" : alert.textFields![2].text
            let index = self.findIngredientIndex(name: self.ingredientName!)
            if index == -1 {
                self.createNewIngredient(name: self.ingredientName!, url: self.ingredientImageUrl!, quantity: self.ingredientQuantity!)
            } else {
                self.ingredients[index].quantity += self.ingredientQuantity!
            }
            self.tableView.reloadData()
            
        }))
        
        // Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    func addIngredient(withName: String, quantity: Int, url: String, toRecipe: Recipe) {
        let index = findIngredientIndex(name: withName)
        var id: String
        if index == -1 {
            id = createNewIngredient(name: withName, url: url)
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
    
    func createNewIngredient(name: String, url: String) -> String {
        return createNewIngredient(name: name, url: url, quantity: 50)
    }
    
    func createNewIngredient(name: String, url: String, quantity: Int32) -> String {
        let ingredient = Ingredient(context: self.context!)
        ingredient.quantity = quantity
        ingredient.name = name
        ingredient.imageUrl = url
        try? self.context?.save()
        let id = ingredient.objectID.uriRepresentation().absoluteString
        ingredients.append(ingredient)
        return id
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
            for ingredient in self.ingredients {//every ingredientRecipe
                var error = true
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
        cell.imageView?.image = UIImage(named: "placeholder.png")
        // Adding the right informations
        
        if ingredient.imageUrl != nil {
            /*if FileManager.default.fileExists(atPath: ingredient.imageUrl!) {
                print("File exists")
            } else {
                print("File doesn't exist")
            }*/
            let url = URL.init(string: ingredient.imageUrl!)
            if ingredient.imageUrl?.characters.count != 0 && url != nil {
                //downloadImage(url: URL(string: ingredient.imageUrl!)!, cell: cell)
                cell.imageView?.sd_setImage(with: NSURL(string: ingredient.imageUrl!) as URL!)
            }
        }
        
        cell.textLabel?.text = ingredient.name
        cell.detailTextLabel?.text = String(format: "Quantité : %d", ingredient.quantity)
        
        // Returning the cell
        return cell
    }
    
}

