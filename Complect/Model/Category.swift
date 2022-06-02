//
//
// Category.swift
// Complect
//
// Created by sinezeleuny on 29.05.2022
//
        

import Foundation
import CoreData

@objc(Category)
class Category: NSManagedObject, Codable {
    private enum CodingKeys: String, CodingKey {
        case name
        case items
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
            fatalError("Error: NSManagedObject not specified!")
        }

        let entity = NSEntityDescription.entity(forEntityName: "Category", in: context)!
        self.init(entity: entity, insertInto: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.items = try NSSet(array: container.decode([Item].self, forKey: .items))
    }
}
