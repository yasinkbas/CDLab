//
//  LibraryBeanTests.swift
//  PersistentManagerTests
//
//  Created by yasinkbas on 23.05.2020.
//  Copyright © 2020 Yasin Akbaş. All rights reserved.
//

import XCTest
import CoreData
import UIKit
@testable import PersistentManager

class LibraryBeanTests: XCTestCase {
    
    var sut: LibraryBeanProtocol!
    var stack: CoreDataStack!
    var context: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        stack = CoreDataStack()
        stack.setup(storeType: NSInMemoryStoreType, completion: nil)
        context = stack.backgroundContext
        sut = LibraryBean(context: context)
    }
    
    override func tearDownWithError() throws {
        stack = nil
        sut = nil
        context = nil
        try super.tearDownWithError()
    }
    
    func test_init_contexts() {
        XCTAssertEqual(sut.context, context)
    }
    
    func test_createLibraryWithoutImageAndMusic_shouldCreateLibrary() {
        sut.createLibrary(name: "TestLibrary", backgroundImage: nil, musics: [])
        
        let request = Library.fetchRequest() as NSFetchRequest<Library>
        let libraries = try! self.context.fetch(request)
        
        guard let library = libraries.first else {
            XCTFail("library missing")
            return
        }
        
        XCTAssertEqual(libraries.count, 1)
        XCTAssertEqual(library.name, "TestLibrary")
        XCTAssertNil(library.backgroundImage)
        XCTAssertEqual(library.musics, Set<Music>.init())
        XCTAssertEqual(library.createdAt?.timeIntervalSinceNow ?? 0, Date().timeIntervalSinceNow, accuracy: 0.1)
    }
    
    func test_createLibraryWithImage_shouldCreateLibrary() {
        let url = URL(string: "https://picsum.photos/200/300")
        guard let data = try? Data(contentsOf: url!) else {
            XCTFail("the image could not loaded")
            return
        }
        
        let image = UIImage(data: data)
        let pngData = image!.pngData()
        
        sut.createLibrary(name: "TestLibrary", backgroundImage: image, musics: [])
        
        let request = Library.fetchRequest() as NSFetchRequest<Library>
        let libraries = try! self.context.fetch(request)
        
        guard let library = libraries.first else {
            XCTFail("library missing")
            return
        }
        
        XCTAssertEqual(libraries.count, 1)
        XCTAssertEqual(library.name, "TestLibrary")
        XCTAssertEqual(library.backgroundImage, pngData)
        XCTAssertEqual(library.musics, Set<Music>.init())
        XCTAssertEqual(library.createdAt?.timeIntervalSinceNow ?? 0, Date().timeIntervalSinceNow, accuracy: 0.1)
    }
    
    func test_createLibraryWithMusic_shouldCreateLibrary() {
        var musics: [Music] = []
        
        context.performAndWait {
            let music1 = Music(context: context)
            let music2 = Music(context: context)
            musics.append(music1)
            musics.append(music2)
        }
        
        sut.createLibrary(name: "TestLibrary", backgroundImage: nil, musics: musics)
        
        let request = Library.fetchRequest() as NSFetchRequest<Library>
        let libraries = try! self.context.fetch(request)
        
        guard let library = libraries.first else {
            XCTFail("library missing")
            return
        }
        
        XCTAssertEqual(libraries.count, 1)
        XCTAssertEqual(library.name, "TestLibrary")
        XCTAssertNil(library.backgroundImage)
        XCTAssertNotEqual(library.musics, Set<Music>.init())
        XCTAssertEqual(library.createdAt?.timeIntervalSinceNow ?? 0, Date().timeIntervalSinceNow, accuracy: 0.1)
    }
    
    func test_fetchLibraries_shouldReturnLibraries() {
        context.performAndWait {
            _ = Library(context: context)
            _ = Library(context: context)
        }
        
        let libraries = sut.fetchLibraries()
        
        XCTAssertEqual(libraries.count, 2)
    }
    
    func test_filterLibrariesExactWithName_shouldReturnFilteredLibraries() {
        context.performAndWait {
            let library1 = Library(context: context)
            library1.name = "Favorites"
            let library2 = Library(context: context)
            library2.name = "Olds"
        }
        
        let libraries = sut.filterLibraries(with: "Favorites")
        
        XCTAssertEqual(libraries.count, 1)
    }
    
    func test_updateLibrary_shouldUpdateLibrary() {
        var objectID: NSManagedObjectID?
        var oldLibrary: Library?
        
        context.performAndWait {
            oldLibrary = Library(context: context)
            oldLibrary?.name = "Old"
            objectID = oldLibrary?.objectID
        }
        
        let newLibrary = Library(context: context)
        newLibrary.name = "New"
        
        sut.updateLibrary(from: oldLibrary!, to: newLibrary)
        
        let request = Library.fetchRequest() as NSFetchRequest<Library>
        let libraries = try! self.context.fetch(request)
        
        XCTAssertEqual(objectID, oldLibrary?.objectID)
        XCTAssertEqual(oldLibrary!.name, "New")
        XCTAssertEqual(libraries.count, 1)
    }
    
    func test_deleteLibrary_shouldDeleteLibrary() {
        var library: Library?
        
        context.performAndWait {
            library = Library(context: context)
        }
        
        let request = Library.fetchRequest() as NSFetchRequest<Library>
        var libraries = try! context.fetch(request)
        
        XCTAssertEqual(libraries.count, 1)
        
        sut.deleteLibrary(library!)
        
        libraries = try! context.fetch(request)
        
        XCTAssertEqual(libraries.count, 0)
    }
    
    func test_addMusicTo_shouldAddMusicToLibrary() {
        var library: Library?
        var music: Music?
        
        context.performAndWait {
            library = Library(context: context)
            music = Music(context: context)
            sut.addMusic(music!, to: library!)
        }
        
        XCTAssertEqual(library?.musics?.first, music)
        XCTAssertEqual(music?.library, library)
    }
}
