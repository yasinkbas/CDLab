//
//  Access.swift
//  PersistentManagerTests
//
//  Created by yasinkbas on 25.05.2020.
//  Copyright © 2020 Yasin Akbaş. All rights reserved.
//

import Foundation
@testable import CDLab

extension Access {
    @UserDefault("test_access_key", defaultValue: Access.empty, userDefaults: MockUserDefaults())
    static var testCurrent: Access
}
