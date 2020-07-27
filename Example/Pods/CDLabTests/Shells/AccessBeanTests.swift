//
//  AccessBeanTests.swift
//  PersistentManagerTests
//
//  Created by yasinkbas on 25.05.2020.
//  Copyright © 2020 Yasin Akbaş. All rights reserved.
//

import XCTest
@testable import PersistentManager

class AccessBeanTests: XCTestCase {
    
    var sut: AccessBeanProtocol!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = AccessBean(Access.testCurrent)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func test_init_serverURLShouldBeNil() {
        XCTAssertNil(sut.serverURL)
    }
    
    func test_init_secretKeyShouldBeNil() {
        XCTAssertNil(sut.secretKey)
    }
    
    func test_createAccess_shouldCreateAccess() {
        
        sut.createOrUpdateAccess(
            Access(
                serverURL: "https://google.com",
                secretKey: "iamsecret"
            ), completion: nil
        )
        
        XCTAssertEqual(sut.serverURL, "https://google.com")
        XCTAssertEqual(sut.secretKey, "iamsecret")
    }
    
    func test_isExist_accessNotCreated_shouldReturnFalse() {
        let isExist = sut.isExist()
        
        XCTAssertFalse(isExist)
    }
    
    func test_isExist_accessCreated_shouldReturnTrue() {
        sut.createOrUpdateAccess(
            Access(
                serverURL: "https://google.com",
                secretKey: "iamsecret"
            ), completion: nil
        )
        
        let isExist = sut.isExist()
        
        XCTAssertTrue(isExist)
    }
}
