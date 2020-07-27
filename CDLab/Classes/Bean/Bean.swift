//
//  Bean.swift
//  PersistentManager
//
//  Created by Yasin Akbaş on 13.05.2020.
//  Copyright © 2020 Yasin Akbaş. All rights reserved.
//

import Foundation
import CoreData

public protocol Bean {
    var stack: CoreDataStackProtocol { get set }
    var context: NSManagedObjectContext { get set }
}

extension Bean {
    var context: NSManagedObjectContext {
        stack.backgroundContext
    }
}
