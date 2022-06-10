//
//  ViewController.swift
//  Complect
//
//  Created by sinezeleuny on 26.05.2022.
//

import UIKit
import CoreData

class ItemsVC: UITableViewController {
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Добавление товара", message: nil, preferredStyle: .alert)
        ac.view.tintColor = #colorLiteral(red: 0.4122543931, green: 0.2670552135, blue: 0.784809649, alpha: 1)
        ac.addTextField()
        ac.textFields?[0].placeholder = "Название"
        ac.textFields?[0].font = UIFont.systemFont(ofSize: 17.0)
        ac.addTextField()
        ac.textFields?[1].placeholder = "Категория"
        ac.textFields?[1].font = UIFont.systemFont(ofSize: 17.0)
        ac.addTextField()
        ac.textFields?[2].placeholder = "Количество"
        ac.textFields?[2].keyboardType = .numberPad
        ac.textFields?[2].font = UIFont.systemFont(ofSize: 17.0)
        let submitAction = UIAlertAction(title: "Добавить", style: .default) {
            [weak self, weak ac] action in
            guard let itemName = ac?.textFields?[0].text else { return }
            guard let categoryName = ac?.textFields?[1].text else { return }
            guard let quantityString = ac?.textFields?[2].text else { return }
            print(itemName, categoryName, Int(quantityString) ?? 0)
            
            let context = (self?.container.viewContext)!
            
            // fetching category
            var category = Category()
            let predicate = NSPredicate(format: "name = %@", categoryName.lowercased())
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            request.predicate = predicate
            if let supposedCategories = try? context.fetch(request) {
                if let supposedCategory = supposedCategories.first {
                    category = supposedCategory
                } else {
                    category = Category(context: context)
                    category.name = categoryName.lowercased()
                }
            }
            
            // fetching item
            var item = Item()
            let itemPredicate = NSPredicate(format: "name = %@", itemName)
            let itemRequest: NSFetchRequest<Item> = Item.fetchRequest()
            itemRequest.predicate = itemPredicate
            if let supposedItems = try? context.fetch(itemRequest) {
                if let supposedItem = supposedItems.first {
                    item = supposedItem
                    item.quantity += Int64(quantityString) ?? 0
                } else {
                    item = Item(context: context)
                    item.name = itemName
                    item.quantity = Int64(quantityString) ?? 0
                    item.category = category
                }
            }
            
            try? context.save()
            self?.fetchCategories()
        }
        
        ac.addAction(submitAction)
        ac.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        present(ac, animated: true)
        
    }
    
    @IBAction func reloadItems(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Перезагрузить списки товаров и комплектов?", message: nil, preferredStyle: .alert)
        ac.view.tintColor = #colorLiteral(red: 0.4122543931, green: 0.2670552135, blue: 0.784809649, alpha: 1)
        ac.addAction(UIAlertAction(title: "Перезагрузить", style: .default, handler: {[weak self] _ in
            self?.appDelegate.deleteData(context: (self?.container.viewContext)!)
            self?.appDelegate.loadItems(context: (self?.container.viewContext)!)
            self?.appDelegate.loadComplects(context: (self?.container.viewContext)!)

            self?.fetchCategories()
            self?.presentInfoAlert(title: "Данные перезагружены", message: nil)
        }))
        ac.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    private let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var categories: [Category] = []
    
    private func fetchCategories() {
        let context = container.viewContext
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [nameSort]
        if let supposedItems = try? context.fetch(request) {
            categories = supposedItems
        }
        tableView.reloadData()
    }
    
    private func fetchItems(in category: Category) -> [Item]? {
        let context = container.viewContext
        if let name = category.name {
            let predicate = NSPredicate(format: "category.name = %@", name)
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            let nameSort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSort]
            request.predicate = predicate
            return try? context.fetch(request)
        }
        return nil
        
    }
    
    func checkForEmptyCategories() {
        for category in categories {
            if let items = fetchItems(in: category) {
                if items.isEmpty {
                    container.viewContext.delete(category)
                    try? container.viewContext.save()
                    fetchCategories()
                }
            }
        }
    }
    
    // MARK: VCLC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 20.0
        }
        
        title = "Товары"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCategories()
    }

    // MARK: TableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section].name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = fetchItems(in: categories[section]) {
            return items.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath)
        if let items = fetchItems(in: categories[indexPath.section]) {
            if let cell = cell as? ItemCell {
                var numberOfRowsAbove = 0
                for number in 0..<tableView.numberOfSections {
                    if number == indexPath.section {
                        break
                    }
                    numberOfRowsAbove += tableView.numberOfRows(inSection: number)
                }
                cell.numberLabel.text = "\(indexPath.row + 1 + numberOfRowsAbove)"
                cell.titleLabel.text = "\(items[indexPath.row].name ?? "")"
                if items[indexPath.row].quantity <= 0 {
                    cell.checkmarkImage.isHidden = true
                } else {
                    cell.checkmarkImage.isHidden = false
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let items = fetchItems(in: categories[indexPath.section]) {
                container.viewContext.delete(items[indexPath.row])
                try? container.viewContext.save()
                tableView.deleteRows(at: [indexPath], with: .fade)
                fetchCategories()
                checkForEmptyCategories()
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
}

