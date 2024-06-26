//
//
// ListVC.swift
// Complect
//
// Created by sinezeleuny on 01.06.2022
//
        

import UIKit
import CoreData

class ListVC: UITableViewController {
    @IBAction func reloadData(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Перезагрузить списки товаров и комплектов?", message: nil, preferredStyle: .alert)
        ac.view.tintColor = #colorLiteral(red: 0.4122543931, green: 0.2670552135, blue: 0.784809649, alpha: 1)
        ac.addAction(UIAlertAction(title: "Перезагрузить", style: .default, handler: {[weak self] _ in
            self?.appDelegate.deleteData(context: (self?.container.viewContext)!)
            self?.appDelegate.loadItems(context: (self?.container.viewContext)!)
            self?.appDelegate.loadComplects(context: (self?.container.viewContext)!)
            self?.presentInfoAlert(title: "Данные перезагружены", message: nil)
        }))
        ac.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    @IBAction func cleanList(_ sender: UIBarButtonItem) {
        
        let ac = UIAlertController(title: "Очистить корзину?", message: nil, preferredStyle: .alert)
        ac.view.tintColor = #colorLiteral(red: 0.4122543931, green: 0.2670552135, blue: 0.784809649, alpha: 1)
        ac.addAction(UIAlertAction(title: "Очистить", style: .default, handler: {[weak self] _ in
            
            for item in (self?.items)! {
                self?.container.viewContext.delete(item)
            }
            try? self?.container.viewContext.save()
            self?.fetchItems()
            self?.tableView.reloadData()
        }))
        ac.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    private let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    var items: [ListItem] = []
    
    private var deleted = false
    
    private func fetchItems() {
        let context = container.viewContext
        let request: NSFetchRequest<ListItem> = ListItem.fetchRequest()
        if let supposedItems = try? context.fetch(request) {
            items = supposedItems
        }
        
    }
    
    // MARK: VCLC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 20.0
        }

        title = "Корзина"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchItems()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Товары для закупки"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if items.isEmpty {
            if deleted {
                return 0
            }
            return 1
        }
        return items.count
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if items.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Empty", for: indexPath)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "List", for: indexPath)
            if let cell = cell as? ListCell {
                cell.titleLabel.text = items[indexPath.row].name
                cell.quantityLabel.text = "\(items[indexPath.row].quantity)"
            }
            
            return cell
        }
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if items.isEmpty {
            return false
        }
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            container.viewContext.delete(items[indexPath.row])
            try? container.viewContext.save()
            fetchItems()
            
//            if items.isEmpty {
//                inserted = true
//                tableView.insertRows(at: [indexPath], with: .none)
//            }
            deleted = true
            tableView.deleteRows(at: [indexPath], with: .fade)
            deleted = false
            if items.isEmpty {
                tableView.reloadData()
            }
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
