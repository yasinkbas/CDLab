//
//  Persist.swift
//  PersistentManager
//
//  Created by yasinkbas on 25.05.2020.
//  Copyright © 2020 Yasin Akbaş. All rights reserved.
//

import Foundation

@propertyWrapper
public struct UserDefault<T: Codable> {
    let key: String
    let defaultValue: T
    let userDefaults: UserDefaults
    
    public init(_ key: String, defaultValue: T, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }
    
    public var wrappedValue: T {
        get {
            if let data = userDefaults.object(forKey: key) as? Data,
                let value = try? JSONDecoder().decode(T.self, from: data) {
                return value
            }
            return  defaultValue
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                userDefaults.set(encoded, forKey: key)
            }
        }
    }
}
