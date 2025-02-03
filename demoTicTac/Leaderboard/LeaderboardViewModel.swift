//
//  LeaderboardViewModel.swift
//  demoTicTac
//
//  Created by PavelMac on 2/02/2025.
//  Copyright © 2025 Monitoreal – Smart Monitoring LLC. All rights reserved.
//

import UIKit

struct LeaderboardViewModel {
    
    let positionId: String
    let gameTime: String
    let waysCount: String
    let userFullName: String
    
    init(with board: Leaderboard) {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.maximumFractionDigits = 2
        positionId  = "\(board.leaderboardPosition + 1)."
        gameTime = (formatter.string(from: NSNumber(value:board.individualTime)) ?? "") + " sec"
        waysCount = "\(board.waysCount)"
        userFullName = "\(board.userFullName ?? "")"
    }
}
