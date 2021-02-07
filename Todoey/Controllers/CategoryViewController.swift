//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Michael Chen on 12/31/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
   
    let realm = try! Realm()
    
    //Results is a auto updating container
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.separatorStyle = .none
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist")
        }
        
        navBar.backgroundColor = UIColor(hexString: "3390FE")
        
        //reload table view to get cell back to it saved color
        tableView.reloadData()
        
    }

    
    //MARK: - Table view data source methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get cell from super class (the cell created in the cellForRowAt method in SwipeTableViewController)
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row]{
            cell.textLabel?.text = category.name
            
            
            guard let categoryColor = UIColor(hexString: category.Color) else{
                fatalError("Error creating color")
            }
            
            cell.backgroundColor = categoryColor
            
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
        else{
            cell.textLabel?.text = "No Categories added yet"
        }
        
        return cell

    }

    
    
    //MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    //this will be perform just before segue is done
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
    
        //indexPath for row that is selected
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    
    //MARK: - Data Manipulation methods
    
    func save(category: Category){
        
        do {
            try realm.write({
                realm.add(category)
            })
            
        } catch {
            print("Error saving context, \(error.localizedDescription)")
        }
        
        tableView.reloadData()
    }
    
    
    
    func loadCategories(){

        /*will fetch all item inside realm db that are of type Category object
         returns a Results<Category>
         BY ASSIGNING TO categories here, IT TRIGGER THE AUTO UPDATED OF A RESULTS OBJECT SINCE
         catergories IS OF TYPE RESULT
         */
        categories = realm.objects(Category.self)

        tableView.reloadData()
    }
    
    
    
    //MARK: - Delete data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categories?[indexPath.row]{
            
            print("Categoryviewcontroller updatemodel")
            
            do {
                try self.realm.write({
                    self.realm.delete(category)
                })
                
            } catch {
                print("Error delete catergory, \(error.localizedDescription)")
            }
        }
    }
    
    
    
    //MARK: - Add New Catergories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            //what will happen onces the user clicks the Add button on the alert
            print(textField.text ?? "")
            
            if textField.text == ""{
                let alert = UIAlertController(title: "Category cannot be blank", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                print("ADDED")
                
                let newCategory = Category()
                newCategory.name = textField.text!
                newCategory.Color = UIColor.randomFlat().hexValue()
                
                /*
                 DON'T NEED TO APPEND ANYMORE SINCE catergories IS OF TYPE RESULTS WHICH IS
                 A AUTO UPDATED CONTAINER
                 */
                //self.categories.append(newCategory)

                self.save(category: newCategory)
                
                
            }
            
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add category"
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    

}


