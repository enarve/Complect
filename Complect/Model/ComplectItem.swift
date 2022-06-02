//
//
// ComplectItem.swift
// Complect
//
// Created by sinezeleuny on 31.05.2022
//
        

import Foundation
import CoreData

@objc(ComplectItem)
class ComplectItem: NSManagedObject, Codable {
    private enum CodingKeys: String, CodingKey {
        case name, quantity, isRequired, isIncluded
    }
    
    func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(quantity, forKey: .quantity)
            try container.encode(isRequired, forKey: .isRequired)
            try container.encode(isIncluded, forKey: .isIncluded)
    }

    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
            fatalError("Error: NSManagedObject not specified!")
        }

        let entity = NSEntityDescription.entity(forEntityName: "ComplectItem", in: context)!
        self.init(entity: entity, insertInto: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.quantity = try container.decode(Int64.self, forKey: .quantity)
        self.isRequired = try container.decode(Bool.self, forKey: .isRequired)
        if isRequired {
            self.isIncluded = true
        } else {
            self.isIncluded = false
        }
      }
}
