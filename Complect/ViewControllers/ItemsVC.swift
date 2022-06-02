//
//  ViewController.swift
//  Complect
//
//  Created by sinezeleuny on 26.05.2022.
//

import UIKit
import CoreData

class ItemsVC: UITableViewController {
    
    private let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer

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
}
