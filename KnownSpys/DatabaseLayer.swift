//
//  DatabaseLayer.swift
//  KnownSpys
//
//  Created by Mathieu Janneau on 31/01/2022.
//  Copyright © 2022 JonBott.com. All rights reserved.
//

import Foundation
import CoreData
import UIKit

typealias SpiesBlock = ([Spy]) -> Void

protocol DatabaseLayer {
    func save(dtos: [SpyDTO], translationLayer: TranslationLayer, finished: @escaping () -> Void)
    func loadFromDB(finished: SpiesBlock)
}

class DatabaseLayerImpl: DatabaseLayer {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "KnownSpys")
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save(dtos: [SpyDTO], translationLayer: TranslationLayer, finished: @escaping () -> Void) {
        clearOldResults()
        
        _ = translationLayer.toUnsavedCoreData(from: dtos, with: mainContext)
        
        try! mainContext.save()
        
        finished()
    }
    
    func loadFromDB(finished: SpiesBlock) {
        print("loading data locally")
        let spies = loadSpiesFromDB()
        finished(spies)
    }
    
    fileprivate func loadSpiesFromDB() -> [Spy] {
        let sortOn = NSSortDescriptor(key: "name", ascending: true)
        
        let fetchRequest: NSFetchRequest<Spy> = Spy.fetchRequest()
        fetchRequest.sortDescriptors = [sortOn]
        
        let spies = try! persistentContainer.viewContext.fetch(fetchRequest)
        
        return spies
    }
    
    //MARK: - Helper Methods
    fileprivate func clearOldResults() {
        print("clearing old results")
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Spy.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        try! persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: persistentContainer.viewContext)
        persistentContainer.viewContext.reset()
    }

}

