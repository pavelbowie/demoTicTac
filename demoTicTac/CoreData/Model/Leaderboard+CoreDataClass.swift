//
//  Leaderboard+CoreDataClass.swift
//  demoTicTac
//
//  Created by PavelMac on 2/02/2025.
//  Copyright © 2025 Monitoreal – Smart Monitoring LLC. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Leaderboard)
public class Leaderboard: NSManagedObject, Codable {
    
    enum Leaderboard: Error {
        case decoder_no_entity_description
    }

    private enum LeaderboardUserPersonKeys: String,CodingKey {
        case userFullName
        case leaderboardPosition
        case individualTime
        case waysCount
        case identifierId
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: LeaderboardUserPersonKeys.self)
        
        try container.encode(self.userFullName, forKey: .userFullName)
        try container.encode(self.leaderboardPosition, forKey: .leaderboardPosition)
        try container.encode(self.individualTime, forKey: .individualTime)
        try container.encode(self.waysCount, forKey: .waysCount)
        try container.encode(self.identifierId, forKey: .identifierId)
    }
    
    public required override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(from decoder: Decoder) throws {
        let context = CoreDataStack.sharedDataStack.privateQueueManagedObjectContext
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: String(describing:Leaderboard.self), in: context) else {
            throw Leaderboard.decoder_no_entity_description
        }
        
        super.init(entity: entityDescription, insertInto: context)
        
        if let container = try? decoder.container(keyedBy: LeaderboardUserPersonKeys.self) {
            userFullName = try? container.decode(String.self, forKey: .userFullName)
            leaderboardPosition = (try? container.decode(Int16.self, forKey: .leaderboardPosition)) ?? 0
            individualTime = (try? container.decode(Int16.self, forKey: .individualTime)) ?? 0
            waysCount = Int16((try? container.decode(Float.self, forKey: .waysCount)) ?? 0)
            identifierId = try? container.decode(String.self, forKey: .identifierId)
        }
    }
    
    public init(from dict: [String: Any], with context: NSManagedObjectContext) throws {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: String(describing:Leaderboard.self), in: context) else {
            throw Leaderboard.decoder_no_entity_description
        }
        
        super.init(entity: entityDescription, insertInto: context)

        self.userFullName = dict[LeaderboardUserPersonKeys.userFullName.rawValue] as? String
        self.leaderboardPosition = dict[LeaderboardUserPersonKeys.leaderboardPosition.rawValue] as? Int16 ?? 0
        self.waysCount = dict[LeaderboardUserPersonKeys.waysCount.rawValue] as? Int16 ?? 0
        self.individualTime = Int16(dict[LeaderboardUserPersonKeys.individualTime.rawValue] as? Float ?? 0)
        self.identifierId = dict[LeaderboardUserPersonKeys.identifierId.rawValue] as? String
    }
}
