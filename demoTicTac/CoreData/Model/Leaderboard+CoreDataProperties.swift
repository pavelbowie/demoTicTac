//
//  Leaderboard+CoreDataProperties.swift
//  demoTicTac
//
//  Created by PavelMac on 2/02/2025.
//  Copyright © 2025 Monitoreal – Smart Monitoring LLC. All rights reserved.
//
//

import Foundation
import CoreData

extension Leaderboard {
    @NSManaged public var userFullName: String?
    @NSManaged public var leaderboardPosition: Int16
    @NSManaged public var individualTime: Int16
    @NSManaged public var waysCount: Int16
    @NSManaged public var identifierId: String?
}
