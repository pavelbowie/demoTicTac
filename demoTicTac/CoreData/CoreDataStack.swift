//
//  CoreDataStack.swift
//  demoTicTac
//
//  Created by PavelMac on 2/02/2025.
//  Copyright © 2025 Monitoreal – Smart Monitoring LLC. All rights reserved.
//

import CoreData
import Foundation
import UIKit

class CoreDataStack {
    
    static let sharedDataStack = CoreDataStack()
    
    lazy public fileprivate(set) var privateQueueManagedObjectContext: NSManagedObjectContext =  {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.mainQueueManagedObjectContext
        return context
        
    }()
    
    lazy public fileprivate(set) var mainQueueManagedObjectContext: NSManagedObjectContext =  {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.dataCoordinator
        return context
    }()
    
    fileprivate var dataCoordinator: NSPersistentStoreCoordinator
    
    //fileprivate var backgroundNotificationObserver: NotificationObserver?
    
    init() {
        func initCoreData(_ coordinator: NSPersistentStoreCoordinator) -> Bool {
            guard let _ = try? coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil) else {
                return false
            }
            return true
        }
        
        let models = NSManagedObjectModel.mergedModel(from: nil)!
        dataCoordinator = NSPersistentStoreCoordinator(managedObjectModel: models)
        _ = initCoreData(dataCoordinator)
        
//        // TODO
//        self.backgroundNotificationObserver = NotificationObserver(notification: UIApplication.didEnterBackgroundNotification.rawValue) { [weak self] _ in
//            self?.privateQueueManagedObjectContext.performAndWait {
//                _ = try? self?.privateQueueManagedObjectContext.save()
//            }
//        }
    }
}
