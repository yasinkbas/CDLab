//
//  MusicBeanTests.swift
//  PersistentManagerTests
//
//  Created by yasinkbas on 23.05.2020.
//  Copyright © 2020 Yasin Akbaş. All rights reserved.
//

import XCTest
import CoreData
@testable import PersistentManager

class MusicBeanTests: XCTestCase {
    
    var sut: MusicBeanProtocol!
    var stack: CoreDataStack!
    var context: NSManagedObjectContext!
    var mockLibrary: Library!

    override func setUpWithError() throws {
        try super.setUpWithError()
        stack = CoreDataStack()
        stack.setup(storeType: NSInMemoryStoreType, completion: nil)
        context = stack.backgroundContext
        sut = MusicBean(context: context)
        mockLibrary = Library(context: context)
    }

    override func tearDownWithError() throws {
        stack = nil
        sut = nil
        context = nil
        mockLibrary = nil
        try super.tearDownWithError()
    }
    
    func test_init_contexts() {
        XCTAssertEqual(sut.context, context)
    }
    
    func test_createMusic_shouldCreateMusic() {
        let libBean = LibraryBean(context: context)
        
        sut.createMusic(name: "Test", file: Data(), library: mockLibrary, bean: libBean)
        
        let request = Music.fetchRequest() as NSFetchRequest<Music>
        let musics = try! self.context.fetch(request)
        
        guard let music = musics.first else {
            XCTFail("music missing")
            return
        }
        
        XCTAssertEqual(music.name, "Test")
        XCTAssertEqual(music.library, mockLibrary)
        XCTAssertEqual(music.file, Data())
        XCTAssertEqual(mockLibrary.musics?.count, 1)
    }
    
    func test_fetchMusics_shouldReturnMusics() {
        context.performAndWait {
            _ = Music(context: context)
            _ = Music(context: context)
        }
        
        let musics = sut.fetchMusics()
        
        XCTAssertEqual(musics.count, 2)
    }
    
    func test_filterMusics_shouldReturnFilteredMusics() {
        context.performAndWait {
            let music1 = Music(context: context)
            music1.name = "Taylor Swift - Shake It Off"
            let music2 = Music(context: context)
            music2.name = "Adele - Hello"
        }
        
        let musics = sut.filterMusics(with: "Adele - Hello")
        
        XCTAssertEqual(musics.count, 1)
    }
    
    func test_updateMusic_shouldUpdateMusic() {
        var objectID: NSManagedObjectID?
        var oldMusic: Music?
        
        self.context.performAndWait {
            oldMusic = Music(context: self.context)
            oldMusic?.name = "Old"
            objectID = oldMusic?.objectID
        }
        
        let newMusic = Music(context: self.context)
        newMusic.name = "New"
        
        sut.updateMusic(from: oldMusic!, to: newMusic)
        
        let request = Music.fetchRequest() as NSFetchRequest<Music>
        let musics = try! self.context.fetch(request)
        
        XCTAssertEqual(objectID, oldMusic?.objectID)
        XCTAssertEqual(oldMusic!.name, "New")
        XCTAssertEqual(musics.count, 1)
    }
    
    func test_deleteMusic_shouldDeleteMusic() {
        var music: Music?
        
        context.performAndWait {
            music = Music(context: context)
        }
        
        let request = Music.fetchRequest() as NSFetchRequest<Music>
        var musics = try! context.fetch(request)
        
        XCTAssertEqual(musics.count, 1)
        
        sut.deleteMusic(music!)
        
        musics = try! context.fetch(request)
        
        XCTAssertEqual(musics.count, 0)
    }
}
