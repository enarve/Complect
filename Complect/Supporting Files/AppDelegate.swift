//
//  AppDelegate.swift
//  Complect
//
//  Created by sinezeleuny on 26.05.2022.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let defaults = UserDefaults.standard

    func didAppAlreadyLaunch() -> Bool {
        let didLaunch = defaults.bool(forKey: "appLaunched")
        if !didLaunch {
            defaults.set(true, forKey: "appLaunched")
        }
        return didLaunch
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if !didAppAlreadyLaunch() {
            persistentContainer.performBackgroundTask { [weak self] context in
                self?.loadItems(context: context)
                self?.loadComplects(context: context)
            }
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: Data loading
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
        func deleteData(context: NSManagedObjectContext) {
            print("Data deletion")
            let itemDeleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
            let itemDeleteRequest = NSBatchDeleteRequest(fetchRequest: itemDeleteFetch)
            let _ = try? context.execute(itemDeleteRequest)
    
    //                try? self?.container.viewContext.save()
    
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            let _ = try? context.execute(deleteRequest)
    
            let complectDeleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Complect")
            let complectDeleteRequest = NSBatchDeleteRequest(fetchRequest: complectDeleteFetch)
            let _ = try? context.execute(complectDeleteRequest)
    
            let complectItemDeleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ComplectItem")
            let complectItemDeleteRequest = NSBatchDeleteRequest(fetchRequest: complectItemDeleteFetch)
            let _ = try? context.execute(complectItemDeleteRequest)
    
        }

    func loadItems(context: NSManagedObjectContext) {
        
        if let jsonUrl = Bundle.main.url(forResource: "Items", withExtension: "json") {
            if let jsonFile = try? Data(contentsOf: jsonUrl) {
                
                    let decoder = JSONDecoder(context: context)
                    if let _: [Category] = try? decoder.decode([Category].self, from: jsonFile) {
                        try? context.save()
                    }
            }
        }
    }
    
    func loadComplects(context: NSManagedObjectContext) {
        if let jsonUrl = Bundle.main.url(forResource: "Complects", withExtension: "json") {
            if let jsonFile = try? Data(contentsOf: jsonUrl) {
                
                    let decoder = JSONDecoder(context: context)
                    if let _: [Complect] = try? decoder.decode([Complect].self, from: jsonFile) {
                        
                        try? context.save()
                    }
            }
        }
    }

}

