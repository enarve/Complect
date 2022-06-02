//
//  Item.swift
//  Complect
//
//  Created by sinezeleuny on 27.05.2022.
//

import Foundation
import CoreData

@objc(Item)
class Item: NSManagedObject, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case name, quantity
    }
    
    func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(quantity, forKey: .quantity)
    }

    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
            fatalError("Error: NSManagedObject not specified!")
        }

        let entity = NSEntityDescription.entity(forEntityName: "Item", in: context)!
        self.init(entity: entity, insertInto: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.quantity = try container.decode(Int64.self, forKey: .quantity)
      }

}

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")!
}

extension JSONDecoder {
    convenience init(context: NSManagedObjectContext) {
        self.init()
        self.userInfo[.context] = context
    }
}
