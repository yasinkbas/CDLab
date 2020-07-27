//
//  StackTests.swift
//  PersistentManagerTests
//
//  Created by Yasin Akbaş on 13.05.2020.
//  Copyright © 2020 Yasin Akbaş. All rights reserved.
//

import XCTest
import CoreData
@testable import PersistentManager

class StackTests: XCTestCase {
    
    var sut: CoreDataStack!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = CoreDataStack()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func test_setup_completionCalled() {
        let setupExpectation = expectation(description: "setup completion called")

        sut.setup(storeType: NSInMemoryStoreType) {
            setupExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func test_setup_persistentStoreInitialized() {
        let setupExpectation = expectation(description: "setup completion called")
        
        sut.setup(storeType: NSInMemoryStoreType) {
            setupExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0) { _ in
            let persistentContainer = self.sut.persistentContainer
            let persistentStores = persistentContainer.persistentStoreCoordinator.persistentStores
            XCTAssertTrue(persistentStores.count > 0)
        }
    }
    
    func test_setup_persistentContainerLoadedOnDisk() {
        let setupExpectation = expectation(description: "setup completion called")
        
        sut.setup {
            let persistentContainer = self.sut.persistentContainer
            let description = persistentContainer.persistentStoreDescriptions.first
            XCTAssertEqual(description?.type, NSSQLiteStoreType, "description type could not set by default")
            setupExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0) { _ in
            try! self.sut.destroyPersistentStore()
        }
    }
    
    func test_setup_persistentContainerLoadInMemory() {
        let setupExpectation = expectation(description: "setup completion called")
        
        sut.setup(storeType: NSInMemoryStoreType) {
            let persistentContainer = self.sut.persistentContainer
            let description = persistentContainer.persistentStoreDescriptions.first
            XCTAssertEqual(description?.type, NSInMemoryStoreType)
            setupExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func test_backgroundContext_concurrencyType() {
        let setupExpectation = expectation(description: "background context")
        
        sut.setup(storeType: NSInMemoryStoreType) {
            XCTAssertEqual(self.sut.backgroundContext.concurrencyType, .privateQueueConcurrencyType)
            setupExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func test_mainContext_concurrencyType() {
        let setupExpectation = expectation(description: "main context")
        
        sut.setup(storeType: NSInMemoryStoreType) {
            XCTAssertEqual(self.sut.mainContext.concurrencyType, .mainQueueConcurrencyType)
            setupExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
}
