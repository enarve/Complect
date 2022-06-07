//
//
// ComplectsVC.swift
// Complect
//
// Created by sinezeleuny on 30.05.2022
//
        

import UIKit
import CoreData

class ComplectsVC: UITableViewController {
    
    @IBAction func reloadComplects(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Перезагрузить списки товаров и комплектов?", message: nil, preferredStyle: .alert)
        ac.view.tintColor = #colorLiteral(red: 0.4117647059, green: 0.2666666667, blue: 0.7843137255, alpha: 1)
        ac.addAction(UIAlertAction(title: "Перезагрузить", style: .default, handler: {[weak self] _ in
            
            self?.appDelegate.deleteData(context: (self?.container.viewContext)!)
            self?.appDelegate.loadItems(context: (self?.container.viewContext)!)
            self?.appDelegate.loadComplects(context: (self?.container.viewContext)!)
            self?.fetchComplects()
            self?.presentInfoAlert(title: "Данные перезагружены", message: nil)

        }))
        ac.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    @IBAction func dropMarks(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Сбросить отметки о собранных комплектах?", message: nil, preferredStyle: .alert)
        ac.view.tintColor = #colorLiteral(red: 0.4122543931, green: 0.2670552135, blue: 0.784809649, alpha: 1)
        ac.addAction(UIAlertAction(title: "Сбросить", style: .default, handler: {[weak self] _ in
            
            for complect in (self?.complects)! {
                complect.collected = false
            }
            try? self?.container.viewContext.save()
            self?.tableView.reloadData()
        }))
        ac.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
                                   
    }
    
    private let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var complects: [Complect] = []
    
    func switchItem(item: ComplectItem?) {
        if let item = item {
            item.isIncluded.toggle()
            try? container.viewContext.save()
//            tableView.reloadData()
        }
        
    }
    
    func collect(complect: Complect?) {
        var thereWereErrors = false
        var somethingAddedToList = false
        if let complect = complect {
            var title = ""
            if complect.collected {
                title = "Собрать «\(complect.name ?? "")» повторно?"
            } else {
                title = "Собрать «\(complect.name ?? "")»?"
            }
            let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            ac.view.tintColor = #colorLiteral(red: 0.4122543931, green: 0.2670552135, blue: 0.784809649, alpha: 1)
            ac.addAction(UIAlertAction(title: "Собрать", style: .default, handler: {[weak self] _ in
                
                if let complectItems = complect.items as? Set<ComplectItem> {
                    for complectItem in Array(complectItems).filter({$0.isIncluded}) {
                        if let item = self?.fetchItem(like: complectItem) {
                            if item.quantity >= complectItem.quantity {
                                item.quantity -= complectItem.quantity
                                do { try self?.container.viewContext.save()
                                } catch {
                                    thereWereErrors = true
                                    print(error)

                                }
                            } else {
                                
                                var listItem: ListItem?
                                if let probableListItem = self?.fetchListItem(like: complectItem) {
                                    listItem = probableListItem
                                    listItem?.quantity += complectItem.quantity - item.quantity
                                } else {
                                    listItem = ListItem(context: (self?.container.viewContext)!)
                                    listItem!.name = complectItem.name
                                    listItem!.quantity = complectItem.quantity - item.quantity
                                }
                                item.quantity = 0
                                
                                
                                do { try self?.container.viewContext.save()
                                    somethingAddedToList = true
                                } catch {
                                    thereWereErrors = true
                                    print(error)
                                }
                            }
                            
                            
                        } else {
                            var listItem: ListItem?
                            if let probableListItem = self?.fetchListItem(like: complectItem) {
                                listItem = probableListItem
                                listItem?.quantity += complectItem.quantity
                            } else {
                                listItem = ListItem(context: (self?.container.viewContext)!)
                                listItem!.name = complectItem.name
                                listItem!.quantity = complectItem.quantity
                            }
                            
                            do { try self?.container.viewContext.save()
                                somethingAddedToList = true
                            } catch {
                                thereWereErrors = true
                                print(error)
                            }
                        }
                        
                    }
                    if !thereWereErrors {
                        complect.collected = true
                        self?.tableView.reloadData()
                        try? self?.container.viewContext.save()
                        if somethingAddedToList {
                            self?.presentInfoAlert(title: "Комплект собран", message: "Список пополнен недостающими товарами")
                        } else {
                            self?.presentInfoAlert(title: "Комплект собран", message: nil)
                        }
                    } else {
                        self?.presentInfoAlert(title: "Ошибка", message: "Комплект собрать не удалось")
                    }
                    
                }
                
                
            }))
            ac.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    private func fetchComplects() {
        let context = container.viewContext
        let request: NSFetchRequest<Complect> = Complect.fetchRequest()
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        let daySort = NSSortDescriptor(key: "day", ascending: true)
        request.sortDescriptors = [daySort, nameSort]
        if let supposedComplects = try? context.fetch(request) {
            complects = supposedComplects
        }
        tableView.reloadData()
    }
    
    private func fetchItems(in complect: Complect) -> [ComplectItem]? {
        let context = container.viewContext
        if let name = complect.name {
            let predicate = NSPredicate(format: "ANY complect.name like %@", name)
            let request: NSFetchRequest<ComplectItem> = ComplectItem.fetchRequest()
            let nameSort = NSSortDescriptor(key: "name", ascending: true)
            let requireSort = NSSortDescriptor(key: "isRequired", ascending: false)
            request.sortDescriptors = [requireSort, nameSort]
            request.predicate = predicate
            return try? context.fetch(request)
        }
        return nil
    }
    
    private func fetchItem(like complectItem: ComplectItem) -> Item? {
        let context = container.viewContext
        if let name = complectItem.name {
            let predicate = NSPredicate(format: "name = %@", name)
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            request.predicate = predicate
            return try? context.fetch(request).first
        }
        return nil
    }
    
    private func fetchComplectItem(like complectItem: ComplectItem) -> ComplectItem? {
        let context = container.viewContext
        if let name = complectItem.name {
            let predicate = NSPredicate(format: "name = %@", name)
            let request: NSFetchRequest<ComplectItem> = ComplectItem.fetchRequest()
            request.predicate = predicate
            return try? context.fetch(request).first
        }
        return nil
    }
    
    private func fetchListItem(like complectItem: ComplectItem) -> ListItem? {
        let context = container.viewContext
        if let name = complectItem.name {
            let predicate = NSPredicate(format: "name = %@", name)
            let request: NSFetchRequest<ListItem> = ListItem.fetchRequest()
            request.predicate = predicate
            return try? context.fetch(request).first
        }
        return nil
    }
    
    private func getSectionHeaders() -> [Int] {
        var headers: [Int] = []
        for complect in complects {
            if headers.contains(Int(complect.day)) {
                headers.append(0)
            } else {
                headers.append(Int(complect.day))
            }
        }
        return headers
    }
    
    private func getDays() -> [Int] {
        var numbers: [Int] = []
        for complect in complects {
            let day = Int(complect.day)
            if !numbers.contains(day) {
                numbers.append(day)
            }
        }
        return numbers
    }
    
    private func getDayString(number: Int) -> String {
        switch number {
            case 1: return "Понедельник"
            case 2: return "Вторник"
            case 3: return "Среда"
            case 4: return "Четверг"
            case 5: return "Пятница"
            case 6: return "Суббота"
            case 7: return "Воскресенье"
            default: return ""
        }
    }
    
    private func getItems(in day: Int) -> [[ComplectItem]] {
        var dayItems: [[ComplectItem]] = []
        for complect in complects {
            if complect.day == getDays()[day] {
                if let items = fetchItems(in: complect) {
                    dayItems.append(items)
                }
            }
        }
        return dayItems
    }
    
    // MARK: VCLC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 20.0
        }

        title = "Комплекты"
        navigationController?.navigationBar.prefersLargeTitles = true
//        fetchComplects()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchComplects()
//        tableView.setNeedsLayout()
//        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return complects.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getDayString(number: getSectionHeaders()[section])
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = fetchItems(in: complects[section]) {
            return items.count + 1
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 90.0
        } else {
            return 45.0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Complect Info", for: indexPath)
            
            if let cell = cell as? ComplectInfoCell {
                cell.complect = complects[indexPath.section]
                cell.infoLabel.text = complects[indexPath.section].text
                cell.titleLabel.text = complects[indexPath.section].name
                let largeConfig = UIImage.SymbolConfiguration(scale: .large)
                if complects[indexPath.section].collected {
                    cell.buyButton.setImage(UIImage(systemName: "checkmark", withConfiguration: largeConfig), for: .normal)
//                    cell.buyButton.isHidden = true
//                    cell.checkmarkImageView.isHidden = false
                } else {
                    cell.buyButton.setImage(UIImage(systemName: "arrow.down.to.line", withConfiguration: largeConfig), for: .normal)
                    
//                    cell.buyButton.isHidden = false
//                    cell.checkmarkImageView.isHidden = true
                }
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "Complect", for: indexPath)
            
            if let cell = cell as? ComplectCell {
                if let items = fetchItems(in: complects[indexPath.section]) {
                    cell.item = items[indexPath.row - 1]
                    cell.titleLabel.text = items[indexPath.row - 1].name
                    cell.quantityLabel.text = "\(items[indexPath.row - 1].quantity)"
                    if !items[indexPath.row - 1].isRequired {
                        cell.switcher.isHidden = false
                    } else {
                        cell.switcher.isHidden = true
                    }
                    if !items[indexPath.row - 1].isRequired {
                        if items[indexPath.row - 1].isIncluded {
                            cell.titleLabel.textColor = UIColor.label
                            cell.switcher.isOn = true
                        } else {
                            cell.titleLabel.textColor = UIColor.secondaryLabel
                            cell.switcher.isOn = false
                        }
                    } else {
                        cell.titleLabel.textColor = UIColor.label
                        cell.switcher.isOn = false
                    }
                    if complects[indexPath.section].collected {
                        cell.switcher.isEnabled = false
                    } else {
                        cell.switcher.isEnabled = true
                    }
                    
                    
                }
            }
        }
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

extension UIViewController {
    func presentInfoAlert(title: String?, message: String?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.view.tintColor = #colorLiteral(red: 0.4122543931, green: 0.2670552135, blue: 0.784809649, alpha: 1)
        ac.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
}
