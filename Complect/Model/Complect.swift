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
        case name, text, day, items, collected
    }
    
    func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(text, forKey: .text)
            try container.encode(day, forKey: .day)
            try container.encode(day, forKey: .collected)
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
        self.collected = try container.decode(Bool.self, forKey: .collected)
        
        self.items = try NSSet(array: container.decode([ComplectItem].self, forKey: .items))
        
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
