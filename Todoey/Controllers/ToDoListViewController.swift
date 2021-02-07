//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

/*By inheriting from UITableViewController we don't need to assign this viewcontroller
  as the tableview delegate and datasource, it's all taken care of
 */
class ToDoListViewController: SwipeTableViewController {
    
    var todoItems: Results<Item>?
    
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        //once this variable is set trigger code
        didSet{
            loadItems()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.separatorStyle = .none
        
    }
    
    //will be call right before view load onto screen
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.Color{
            
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
            
            
            if let navBarColor = UIColor(hexString: colorHex){
                navBar.backgroundColor = navBarColor
                
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
            }
            
            
        }
    }
    
    
    
    
    
    
    
    //MARK: - TableView datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
           
            //getting color of catergory and using it as color for item and each cell will be a shade
            //darker than the previous cell
            if let color = UIColor(hexString: self.selectedCategory!.Color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)){
                
                //change color darkness/tone base on position in array, farther down will be darker
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            //cell.accessoryType = item.done ? .checkmark : .none
            if item.done == true{
                cell.accessoryType = .checkmark
            }
            else{
                cell.accessoryType = .none
            }
        }
        else{
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    
    //MARK: - Tableview Delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row]{
            
            do {
                try realm.write({
    
                    item.done.toggle()
                    
                    //to delete item from realm db
                    ////realm.delete(item)
                })
            } catch {
                print("Error saving status, \(error)")
            }
        }
                
        //have the gray highligh blink away when a row is tapped
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.reloadData()
    }
    
    
    
    //MARK: - Add new items to list
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen onces the user clicks the Add Item button on the alert
            print(textField.text ?? "")
            
            if textField.text == ""{
                let alert = UIAlertController(title: "Item cannot be blank", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                
                
                
                if let currentCategory = self.selectedCategory {
        
                    do {
                        try self.realm.write({
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date()
                            
                            //using relationship between category and items
                            currentCategory.items.append(newItem)
                            
                        })
                        
                    } catch {
                        print("Error saving context, \(error.localizedDescription)")
                    }
                    
                }
                
                self.tableView.reloadData()
            }
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    func loadItems(){

        //using category and item relationship here to get all item for a certain category
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }
    
    
    //MARK: - override super class updateModel method
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.todoItems?[indexPath.row]{
            
            print("toDoListviewcontroller updatemodel")
            
            do {
                try self.realm.write({
                    self.realm.delete(item)
                })
                
            } catch {
                print("Error deleting item, \(error.localizedDescription)")
            }
        }
    }
    
    
}





//MARK: - Searching for item in list
extension ToDoListViewController: UISearchBarDelegate {

    //when user enter text into search bar and press enter
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //cd means case and diacrtic insenstive (don't care about case and accents on words)
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()

    }




    /*go back to original list
      trigger when a letter change in search bar or if it is cleared
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //when search bar get cleared
        if searchBar.text?.count == 0 {
            //fetch all item from persistent store since calling method with default value
            loadItems()

            DispatchQueue.main.async {
                //make keyboard go away, make it so the search bar is not longer selected
                searchBar.resignFirstResponder()
            }
        }
    }




}

