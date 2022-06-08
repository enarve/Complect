//
//
// Complect.swift
// Complect
//
// Created by sinezeleuny on 29.05.2022
//
        

import Foundation
import CoreData

@objc(Complect)
class Complect: NSManagedObject, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case name, text, day, items, isCollected
    }
    
    func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(text, forKey: .text)
            try container.encode(day, forKey: .day)
            try container.encode(isCollected, forKey: .isCollected)
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
            fatalError("Error: NSManagedObject not specified!")
        }

        let entity = NSEntityDescription.entity(forEntityName: "Complect", in: context)!
        self.init(entity: entity, insertInto: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.text = try container.decode(String.self, forKey: .text)
        self.day = try container.decode(Int64.self, forKey: .day)
        self.isCollected = try container.decode(Bool.self, forKey: .isCollected)
        
        self.items = try NSSet(array: container.decode([ComplectItem].self, forKey: .items))
        
        self.indexName = self.name! + "\(self.day)"
        var duplicateNotFound = true
        repeat {
            duplicateNotFound = true
            if let indexName = self.indexName {
                let predicate = NSPredicate(format: "indexName = %@", indexName)
                let request: NSFetchRequest<Complect> = Complect.fetchRequest()
                request.predicate = predicate
                if let result = try? context.fetch(request) {
                    if !result.isEmpty {
                        if result.count > 1 {
                            self.indexName = indexName + "0"
    //                        print(self.indexName!)
                            duplicateNotFound = false
                        }
                    }
                }
            }
        } while !duplicateNotFound
        
        
//        let itemNames = try container.decode([String].self, forKey: .items)
//        var probableItems: [Item] = []
//        for itemName in itemNames {
//            if let itemsFound = findItem(itemName: itemName, in: context) {
//                probableItems += itemsFound
//            }
//        }
//        self.items = NSSet(array: probableItems)
        
    }
    
    func findItem(itemName: String, in context: NSManagedObjectContext) -> [Item]? {
            let predicate = NSPredicate(format: "name = %@", itemName)
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            request.predicate = predicate
            return try? context.fetch(request)
    }
}
