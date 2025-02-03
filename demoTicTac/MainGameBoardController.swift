//
//  MainGameBoardController.swift
//  demoTicTac
//
//  Created by PavelMac on 1/02/2025.
//  Copyright © 2025 Monitoreal – Smart Monitoring LLC. All rights reserved.
//

import UIKit

class MainGameBoardController: UIViewController {
 
    @IBOutlet weak var board: GameBoardViewModel!
    
    @IBOutlet weak var showLeaderboardButton: UIButton! = nil {
        didSet {
            showLeaderboardButton.isHidden = false //TEST
        }
    }
    
    var playerIsCross = true //false
    var playerWin = false
    
    var startTime: Date?
    var waysCount: Int = 1
    
    @IBOutlet private var playerStartButton: UIButton!
    @IBOutlet private var phoneStartButton: UIButton!
    
    var state: GameBoardControllerState = .started  {
        didSet {
            switch state {
            case .started:
                self.startTime = Date()
                self.playerWin = false
                self.waysCount = 1
                self.board.clear()
                self.board.isUserInteractionEnabled = true
            case .ended:
                if playerWin, let startTime = startTime {
                    let time = Date().timeIntervalSinceReferenceDate - startTime.timeIntervalSinceReferenceDate
                    let userFullName = playerIsCross ? "CROSS": "CIRCLE"
                    
                    self.urlClient.postLeaderboardScore(with: userFullName, waysCount: self.waysCount, gameTime: Float(time))
                }
                self.board.isUserInteractionEnabled = false
            }
        }
    }
    
    let urlClient = BackendServerClient()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkGameBoardReachability()
        
        self.state = .started
        self.board.delegate = self
        self.playerStartButton.setTitle(NSLocalizedString("player_start_button", comment: ""), for:.normal)
        self.phoneStartButton.setTitle(NSLocalizedString("phone_start_button", comment: ""), for: .normal)
    }
    
    @IBAction func playerStart() {
        self.state = .started
    }
    
    @IBAction func phoneStart() {
        self.state = .started
        playPhone()
    }
}


extension MainGameBoardController: GameBoardDelegate {
    
    func evaluateGameBoardChange(_ board: GameBoardViewModel, player: GameBoardPlayerType, config: GameBoardConfig, position: GameBoardPosition)
    {
        waysCount += 1
        
        play(board, player: player, config: config, position: position)
        
        if self.state != .ended
        {
            playPhone()   
        }
    }
}


private extension MainGameBoardController {
    
    func playPhone() {
        let config = board.config
        let phoneScreenPosition = config.winLastMove(forSelectingCross: !playerIsCross) ?? config.defenseMove(forSelectingCross: !playerIsCross) ?? config.attackUserMove(forSelectingCross: !playerIsCross)
        if let phoneScreenPosition = phoneScreenPosition {
            play(board, player: .phone, config: board.config, position: phoneScreenPosition)
        }
    }
    
    func play(_ board: GameBoardViewModel,
              player: GameBoardPlayerType,
              config: GameBoardConfig,
              position: GameBoardPosition) {
        
        let newUserPlayerState: State = playerIsCross ? .crossSelected: .circleSelected
        let newPhonePlayerState: State = playerIsCross ? .circleSelected: .crossSelected
        let newState = player == .player ? newUserPlayerState: newPhonePlayerState
        
        let newConfig = GameBoardConfig(board: config.states, newState: newState, atPosition: position)
        
        board.config = newConfig
        
        if let finalRow = board.config.isComplete() {
            board.highlight(finalRow)
            self.playerWin = player == .player
            self.state = .ended
        }
    }
}


private extension MainGameBoardController {
    func checkGameBoardReachability() {
        urlClient.getLeaderboardScore() { [weak self] _, error in
            if case .none = error {
                self?.showLeaderboardButton.isHidden = true
            }
        }
    }
}
