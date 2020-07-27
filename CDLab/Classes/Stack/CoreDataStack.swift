//
//  CoreDataStack.swift
//  PersistentManager
//
//  Created by Yasin Akbaş on 9.05.2020.
//  Copyright © 2020 Yasin Akbaş. All rights reserved.
//

import Foundation
import CoreData
import QueryKit

enum DBError: Error {
    case raw(String)
}

public protocol CoreDataStackProtocol {
    var persistentContainer: NSPersistentContainer  { get }
    var backgroundContext: NSManagedObjectContext   { get }
    var mainContext: NSManagedObjectContext         { get }
    
    func destroyPersistentStore() throws
    func loadPersistentStore(completion: (() -> Void)?)
    func setup(storeType: String, completion: (() -> Void)?)
    
    func fetchAll<Model: NSManagedObject>(context: NSManagedObjectContext) -> QuerySet<Model>
//    func search<Model: NSManagedObject>(context: NSManagedObjectContext, predicate: Predicate<Model>) -> QuerySet<Model>
    func filter<Model: NSManagedObject>(context: NSManagedObjectContext, predicate: Predicate<Model>) -> QuerySet<Model>
}

public class CoreDataStack: CoreDataStackProtocol {    
    private var storeType: String!
    
    let identifier: String
    let model: String
    
    public init(identifier: String, model: String) {
        self.identifier = identifier
        self.model = model
    }
    
    lazy var managedObjectModel: NSManagedObjectModel? = {
        let bundle = Bundle(identifier: self.identifier)!
        let modelURL = bundle.url(forResource: self.model, withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        
        return managedObjectModel
    }()
    
    public lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.model, managedObjectModel: managedObjectModel!)
        let description = container.persistentStoreDescriptions.first
        description?.type = storeType
        
        return container
    }()
    
    public lazy var backgroundContext: NSManagedObjectContext = {
        let context = self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return context
    }()
    
    public lazy var mainContext: NSManagedObjectContext = {
        let context = self.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true

        return context
    }()
    
    public func setup(storeType: String = NSSQLiteStoreType, completion: (() -> Void)?) {
        self.storeType = storeType
        
        loadPersistentStore {
            completion?()
        }
    }
    
    public func loadPersistentStore(completion: (() -> Void)?) {
        persistentContainer.loadPersistentStores { _, error in
            if error != nil {
                fatalError("Unresolved error \(String(describing: error))")
            }
            
            completion?()
        }
    }
    
    public func destroyPersistentStore() throws {
        let coordinator = persistentContainer.persistentStoreCoordinator
        let stores = coordinator.persistentStores
        guard let storeUrl = stores.first?.url else {
            throw DBError.raw("Missing store url")
        }
        
        do {
            try coordinator.destroyPersistentStore(at: storeUrl, ofType: storeType, options: nil)
        } catch {
            throw DBError.raw("Unable to destroy persistent store \(error)")
        }
    }
}

public extension CoreDataStack {
    func fetchAll<Model: NSManagedObject>(
        context: NSManagedObjectContext
    ) -> QuerySet<Model> {
        QuerySet<Model>(context, String(describing: Model.self))
    }
    
//    func search<Model: NSManagedObject>(
//        context: NSManagedObjectContext,
//        predicate: Predicate<Model>
//    ) -> QuerySet<Model> {
//        filter(context: context, predicate: predicate)
//    }
    
    func filter<Model: NSManagedObject>(
        context: NSManagedObjectContext,
        predicate: Predicate<Model>
    ) -> QuerySet<Model> {
        QuerySet<Model>(context, String(describing: Model.self)).filter(predicate)
    }
}

