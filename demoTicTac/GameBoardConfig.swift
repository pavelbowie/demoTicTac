//
//  GameBoardConfig.swift
//  demoTicTac
//
//  Created by PavelMac on 2/02/2025.
//  Copyright © 2025 Monitoreal – Smart Monitoring LLC. All rights reserved.
//

import Foundation

enum GameBoardControllerState {
    case started
    case ended
}

public enum State {
    case undefined
    case crossSelected
    case circleSelected
}

public struct GameBoardPosition: Equatable {
    var column: Int
    let row: Int
    var isValid: Bool {
        let valid =  (0...2 ~= self.column) && (0...2 ~= self.row)
        return valid
    }
    
    static public func == (lhs: GameBoardPosition, rhs:  GameBoardPosition) -> Bool {
        return (lhs.column,lhs.row) == (rhs.column,rhs.row)
    }
    
    func toIndex() -> Int {
        return row * 3 + column
    }
    
    init( fromIndex index: Int) {
        column = index % 3
        row = index / 3
    }
    
    init (column: Int, row: Int) {
        self.column = column
        self.row = row
    }
}

public class GameBoardPositionGenerator: IteratorProtocol {
    let max: (columns:Int,rows:Int) = (3,3)
    var currentPos: GameBoardPosition
    init() {
        currentPos = GameBoardPosition(column: -1 , row:0)
    }
    public func next() -> GameBoardPosition? {
        currentPos = GameBoardPosition(column: currentPos.column + 1 , row: currentPos.row)
        if currentPos.column < max.columns {
            return currentPos
        }
        currentPos = GameBoardPosition(column: 0 , row: currentPos.row + 1)
        currentPos.column = 0
        
        if currentPos.row < max.rows {
            return currentPos
        }
        return nil
    }
}

public struct GameBoardPositionSequence: Sequence {
    public func makeIterator() -> GameBoardPositionGenerator {
        return GameBoardPositionGenerator()
    }
}

public struct GameBoardConfig: Equatable {
    public static func ==(lhs: GameBoardConfig, rhs: GameBoardConfig) -> Bool {
        return lhs.states == rhs.states
    }

    let validationRows: [[GameBoardPosition]] = {
        let firstRow = [GameBoardPosition(column:0,row:0), GameBoardPosition(column:1,row:0), GameBoardPosition(column:2,row:0)]
        let secondRow = [GameBoardPosition(column:0,row:1), GameBoardPosition(column:1,row:1), GameBoardPosition(column:2,row:1)]
        let thirdRow = [GameBoardPosition(column:0,row:2), GameBoardPosition(column:1,row:2), GameBoardPosition(column:2,row:2)]
        let firstColumn = [GameBoardPosition(column:0,row:0), GameBoardPosition(column:0,row:1), GameBoardPosition(column:0,row:2)]
        let secondColumn = [GameBoardPosition(column:1,row:0), GameBoardPosition(column:1,row:1), GameBoardPosition(column:1,row:2)]
        let thirdColumn = [GameBoardPosition(column:2,row:0), GameBoardPosition(column:2,row:1), GameBoardPosition(column:2,row:2)]
        let firstDiagonal = [GameBoardPosition(column:0,row:0), GameBoardPosition(column:1,row:1), GameBoardPosition(column:2,row:2)]
        let secondDiagonal = [GameBoardPosition(column:2,row:0), GameBoardPosition(column:1,row:1), GameBoardPosition(column:0,row:2)]
        let rows = [firstRow,secondRow,thirdRow,firstColumn,secondColumn,thirdColumn,firstDiagonal,secondDiagonal]
        return rows
    }()
    
    private func isComplete(_ row: [GameBoardPosition]) -> Bool {
        let  crossCount = row.filter { self[$0] == .crossSelected }.count
        let roundCount =  row.filter { self[$0] == .circleSelected }.count
        let complete =  crossCount == 3 || roundCount == 3
        return complete
    }
    
    static func empty() -> GameBoardConfig {
        let emptyGameStates = (1...9).map { _ in State.undefined }
        return GameBoardConfig(board: emptyGameStates)
    }
    
    var isEmpty: Bool {
        return  self.states.filter { $0 != .undefined }.count == self.states.count
    }
    
    var crossCount: Int {
        return self.states.filter { $0 == .crossSelected }.count
    }
    
    var roundCount: Int {
        return  self.states.filter { $0 == .circleSelected }.count
    }
    
    let states: [State]
    
    subscript(column: Int, row: Int) -> State? {
        return self[GameBoardPosition(column:column, row: row)]
    }
    
    subscript(position: GameBoardPosition) -> State? {
        guard position.isValid else {
            return nil
        }
        return states[position.toIndex()]
    }
    
    init(board: [State], newState: State, atPosition position: GameBoardPosition)
    {
        var newGameBoard = board
        newGameBoard[position.toIndex()] = newState
        self.states = newGameBoard
    }
    
    init(board: [State])
    {
        self.states = board
    }
    
    func isComplete() -> [GameBoardPosition]? {
        let completedRow  = self.validationRows.lazy.filter { self.isComplete($0) }.first
        return completedRow
    }
}


extension GameBoardConfig {
    private func consecutiveCellStateCount(_ row: [GameBoardPosition], state: State) -> Int {
        var count = 0
        var previousPosition: GameBoardPosition? = nil
        
        let invalidState: State = state == .circleSelected ? .crossSelected:  .circleSelected
        for position in row {
            if let previousPosition = previousPosition , self[previousPosition] == invalidState {
                count = 0
            }
            if self[position] == state {
                count += 1
            }
            previousPosition = position
        }
        return count
    }
    
    private func nextUndefinedPosition(startingAtIndex startIndex: Int) -> GameBoardPosition? {
        guard self.isComplete() == nil else {
            return nil
        }
        var index = startIndex
        var position: GameBoardPosition?
        
        while position == nil {
            let newPosition = GameBoardPosition(fromIndex: index)
            if self[newPosition] == .undefined {
                position = newPosition
            }
            index = (index+1) % 9
        }
        return position
    }
    
    private func findPositionToSelect(inRowStates rowStates: [(Int, [GameBoardPosition])]) -> GameBoardPosition?
    {
        var positionToSelect: GameBoardPosition? = nil

        for consecutiveRowsState in rowStates where positionToSelect == nil {
            let positions = consecutiveRowsState.1
            positionToSelect = positions.filter { self[$0] == .undefined }.first
        }
        return positionToSelect
    }
    
    func defenseMove(forSelectingCross selectingRed: Bool) -> GameBoardPosition? {
        let stateToCheck: State = selectingRed ? .circleSelected  : .crossSelected
        let consecutiveStates = self.validationRows.map { self.consecutiveCellStateCount($0, state: stateToCheck) }
        let consecutiveRowsStates = zip(consecutiveStates,self.validationRows).sorted { $0.0 > $1.0 }.filter { $0.0 == 2 }
        let positionToSelect  = findPositionToSelect(inRowStates: consecutiveRowsStates)
        return positionToSelect
    }

    func winLastMove(forSelectingCross selectingRed: Bool) -> GameBoardPosition? {
        let stateToCheck: State = selectingRed ?  .crossSelected: .circleSelected
        
        let consecutiveStates = self.validationRows.map { self.consecutiveCellStateCount($0, state: stateToCheck) }
        let consecutiveRowsStates = zip(consecutiveStates,self.validationRows).sorted { $0.0 > $1.0 }
        let consecutiveWinningRowsStates = consecutiveRowsStates.filter { $0.0 == 2 }
        let positionToSelect  = findPositionToSelect(inRowStates: consecutiveWinningRowsStates)
        return positionToSelect
    }

    
    func attackUserMove(forSelectingCross selectingRed: Bool) -> GameBoardPosition? {
        if (self.crossCount == 0) && selectingRed  {
            if self[GameBoardPosition(column:1, row: 1)] == .undefined {
                return GameBoardPosition(column:1, row: 1)
            }
            let startIndex = Int(arc4random() % 9)
            return nextUndefinedPosition(startingAtIndex:startIndex)
        }
        if (self.roundCount == 0) && !selectingRed {
            if self[GameBoardPosition(column:1, row: 1)] == .undefined {
                return GameBoardPosition(column:1, row: 1)
            }
            let startIndex = Int(arc4random() % 9)
            return nextUndefinedPosition(startingAtIndex:startIndex)
        }

        let stateToCheck: State = selectingRed ?  .crossSelected: .circleSelected
        
        let consecutiveStates = self.validationRows.map { self.consecutiveCellStateCount($0, state: stateToCheck) }
        let consecutiveRowsStates = zip(consecutiveStates,self.validationRows).sorted { $0.0 > $1.0 }
        let positionToSelect  = findPositionToSelect(inRowStates: consecutiveRowsStates)
        return positionToSelect
    }
}
