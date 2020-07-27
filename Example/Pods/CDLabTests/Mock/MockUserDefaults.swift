//
//  MockUserDefaults.swift
//  PersistentManagerTests
//
//  Created by yasinkbas on 25.05.2020.
//  Copyright © 2020 Yasin Akbaş. All rights reserved.
//

import Foundation

class MockUserDefaults : UserDefaults {
    
    convenience init() {
        self.init(suiteName: "Mock User Defaults")!
    }
    
    override init?(suiteName suitename: String?) {
        UserDefaults().removePersistentDomain(forName: suitename!)
        super.init(suiteName: suitename)
    }
}
