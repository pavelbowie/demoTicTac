//
//  FetchScoreRouter.swift
//  demofetchserver
//
//  Created by PavelMac on 3/02/2025.
//

import Foundation
import Kitura
import LoggerAPI
import HeliumLogger

class FetchScoreRouter {
    
    let leaderboardScore = Leaderboard()
    
    func postScore(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard let json = request.body?.asJSON else {
            try response.status(.badRequest).end()
            return
        }
        if let item = LeaderboardItem.item(with: json) {
            leaderboardScore.addScore(item)
        }
        _ = response.send(status: .OK)
        next()
    }
    
   
    func getJSONScores(request : RouterRequest,response : RouterResponse, next : @escaping () -> Void) throws {
        let list = leaderboardScore.all()
        defer {
            next()
        }
        response.status(.OK).send(json: list)
    }
    
    func getHTMLScores(request : RouterRequest,response : RouterResponse, next : @escaping () -> Void) throws {
        defer {
            next()
        }
        let list = leaderboardScore.all()
        let descriptions = list.map { [($0.position ?? 0)+1,$0.name,$0.time,$0.moves] }
        let context = ["leaderboard" : descriptions]
        try response.render("home", context: context)
        
    }
}
