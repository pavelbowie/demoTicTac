//
//  GameBoardConfig.swift
//  demoTicTac
//
//  Created by PavelMac on 2/02/2025.
//  Copyright © 2025 Monitoreal – Smart Monitoring LLC. All rights reserved.
//

import UIKit

@objc enum GameBoardPlayerType: Int {
    case player
    case phone
}

protocol GameBoardDelegate: class {
    func evaluateGameBoardChange(_ board: GameBoardViewModel,
                                 player: GameBoardPlayerType,
                                 config: GameBoardConfig,
                                 position: GameBoardPosition)
}

extension Selector {
    static let cellTouchHandler: Selector = #selector(GameBoardViewModel.cellTouchHandler(_ :))
}

public class GameBoardViewModel: UIView {
    
    weak var delegate: GameBoardDelegate?
    
    @IBOutlet var cells: [GameCell]!
    
    var config = GameBoardConfig.empty() {
        didSet {
            config.states.enumerated().forEach { index,state in
                self.cells[index].state = state
            }
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
        self.layer.borderColor = self.cells.first?.layer.borderColor
        setupGameCellPositions()
        touchHelper()
    }
    
    @objc func cellTouchHandler(_ recognizer: UITapGestureRecognizer) {
        if let cell = recognizer.view as? GameCell, cell.state == .undefined {
            self.delegate?.evaluateGameBoardChange(self, player: .player, config: config, position: cell.position)
        }
    }
    
    func highlight(_ positions: [GameBoardPosition]) {
        let cells = self.cells.filter { positions.contains($0.position) }
        cells.forEach { $0.highlight() }
    }

    func unHighlight(_ positions: [GameBoardPosition]) {
        let cells = self.cells.filter { positions.contains($0.position) }
        cells.forEach { $0.unHighlight() }
    }

    func clear() {
        self.config = GameBoardConfig.empty()
        unHighlight(self.cells.map { $0.position})
    }
}


private extension GameBoardViewModel {
    func setupGameCellPositions() {
        let sortedCells = self.cells.sorted { cell1,cell2 in
            let isLeftOf =  cell1.frame.origin.x < cell2.frame.origin.x
            let isInSameRow = cell1.frame.origin.y == cell2.frame.origin.y
            let isAbove = cell1.frame.origin.y < cell2.frame.origin.y
            let isSortedBefore = isInSameRow ? isLeftOf: isAbove
            return isSortedBefore
        }
        let positions = Array(GameBoardPositionSequence())
        let sortedCellsPositions = zip(sortedCells,positions)
        for (cell,position) in sortedCellsPositions
        {
            cell.position = position
        }
    }
    
    func touchHelper() {
        for cell in cells {
            let recognizer = UITapGestureRecognizer(target: self, action:Selector.cellTouchHandler)
            cell.addGestureRecognizer(recognizer)
        }
    }
}
