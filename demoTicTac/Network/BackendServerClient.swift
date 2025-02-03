//
//  BackendServerClient.swift
//  demoTicTac
//
//  Created by PavelMac on 1/02/2025.
//  Copyright © 2025 Monitoreal – Smart Monitoring LLC. All rights reserved.
//

import CoreData
import Foundation

enum BackendServerClientAPI: String {
    case game = "leaderboard.json"
}

enum BackendServerClientError: Error {
    case decoderError
}

class BackendServerClient {
    
    let manager = SharedNetworkManager.shared
    
    func getLeaderboardScore(callBack onQueue: OperationQueue = OperationQueue.main,
                      using completionBlock: ((_ leaderboard: [BackendServerClientAPI],_ error: Error?) -> ())? = nil) {
        
        manager.getDataWithRelativePath(BackendServerClientAPI.game.rawValue) { [weak self] data, error in
            if let data = data,
            let newLeaderboardScores = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [[String:Any]] {
                self?.merge(newLeaderboardScores: newLeaderboardScores)
                onQueue.addOperation {
                    completionBlock?([], nil)
                }
            } else {
                onQueue.addOperation {
                    let err = error ?? BackendServerClientError.decoderError
                    completionBlock?([],err)
                }
            }
        }
    }
    
    func postLeaderboardScore(with userFullName: String, waysCount: Int, gameTime: Float, callBack onQueue: OperationQueue = .main,using completionBlock: ((_ error: Error?) -> ())? = nil) {
        
        let dict: [String: Any] = ["userFullName": userFullName,
                                   "waysCount": waysCount,
                                   "gameTime": gameTime]
        
        if let data = try? JSONSerialization.data(withJSONObject: dict, options: []) {
            manager.postData(data: data, withRelativePath: BackendServerClientAPI.game.rawValue) { error in
                onQueue.addOperation {
                    completionBlock?(error)
                }
            }
        }
    }
}


extension BackendServerClient {
    func dictionary(with identifier: String, in list: [[String: Any]]) -> [String: Any]? {
        let dict = list.filter { dict in
            let id = dict["identifierId"] as? String ?? ""
            return id == identifier
        }.first
        return dict
    }
    
    func merge(newLeaderboardScores: [[String: Any]]) {
        let fetchRequest = NSFetchRequest<Leaderboard>(entityName:String(describing:Leaderboard.self))
        
        let context = CoreDataStack.sharedDataStack.privateQueueManagedObjectContext
        defer {
            context.perform {
                try? context.save()
            }
        }
        context.performAndWait {
            var scores: [Leaderboard]? = nil
            scores = try? context.fetch(fetchRequest)
            
            guard let oldLeaderboardScores = scores else {
                _ = newLeaderboardScores.compactMap { try? Leaderboard(from: $0, with: context)}
                return
            }
            
            let oldIdentifiers = oldLeaderboardScores.compactMap { $0.identifierId }
            let newIdentifiers = newLeaderboardScores.compactMap { dict in dict["identifierId"] as? String }
            let oldIdentifiersSet  = Set(oldIdentifiers)
            let newIdentifiersSet = Set(newIdentifiers)
            let replaceId = newIdentifiersSet.subtracting(oldIdentifiersSet)
            let mustDeletedId = oldIdentifiersSet.subtracting(newIdentifiersSet)
            let toBeUpdated = oldIdentifiersSet.intersection(newIdentifiersSet)
            toBeUpdated.forEach { identifier in
                let oldScore = oldLeaderboardScores.filter { $0.identifierId == identifier}.first
                let newScoreDict = dictionary(with: identifier, in: newLeaderboardScores)
                if let oldScore = oldScore, let position = newScoreDict?["leaderboardPosition"] as? Int16 {
                    oldScore.leaderboardPosition = position
                }
            }
            
            mustDeletedId.forEach { identifier in
                if let oldScore = oldLeaderboardScores.filter ({ $0.identifierId == identifier}).first {
                    context.delete(oldScore)
                }
            }
            
            replaceId.forEach { identifier  in
                if let newScoreDict = dictionary(with: identifier, in: newLeaderboardScores) {
                    _ = try? Leaderboard(from: newScoreDict, with: context)
                }
            }
        }
    }
}
