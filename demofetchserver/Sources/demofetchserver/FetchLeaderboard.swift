//
//  FetchLeaderboard.swift
//  demofetchserver
//
//  Created by PavelMac on 3/02/2025.
//

import Foundation

struct LeaderboardItem : Codable,Equatable,CustomStringConvertible {
    public var description: String {
        guard let position = position else {
            return "\(name) \t\t \(time) \(moves)"
        }
        return "\(position).\t\t \(name) \t \(time) \(moves)"
    }
    let position : Int?
    let name : String
    let time : Float
    let waysCount : Int
    let identifier : String?
    
    static func item(with json :[String : Any]) -> LeaderboardItem? {
        guard let jsonName = json["userFullName"] as? String,
            let jsonTime = json["gameTime"] as? Float,
            let jsonMoves = json["waysCount"] as? Int else {
                return nil
        }
        let identifier = NSUUID().uuidString
        let name = jsonName
        let time = jsonTime
        let moves = jsonMoves
        return LeaderboardItem(position: nil, name: name, time: time, moves: moves, identifier: identifier)
    }
    
    func item(with position: Int) -> LeaderboardItem {
        return LeaderboardItem(position: position, name: name, time: time, moves: moves, identifier: identifier)
    }
    
    static func ==(lhs : LeaderboardItem, rhs: LeaderboardItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

class Leaderboard {
    let filePath : URL? =  {
        let filename = "leaderboard"
        guard let newPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return nil
        }
        let url = newPath.appendingPathComponent(filename)
        return url
    }()
    var list : [LeaderboardItem] = [] {
        didSet {
            if list != oldValue  {
                save(leaderboard:list)
            }
        }
    }
    
    init() {
        list = loadLeaderboard()
    }

    func addScore(_ score : LeaderboardItem) {
        list = newList(with: score)
    }
    
    func all() -> [LeaderboardItem] {
        return list
    }
}


fileprivate extension Leaderboard {
    func newList(with item : LeaderboardItem) -> [LeaderboardItem] {
        return (list + [item]).sorted { $0.time < $1.time }.enumerated().map { index,item in item.item(with: index) }
    }
    
    func save(leaderboard : [LeaderboardItem]) {
        guard let url = self.filePath,let data = try? JSONEncoder().encode(leaderboard) else {
            return
        }
            
        _ = try? data.write(to: url, options: .atomicWrite)
    }
    
    func loadLeaderboard() -> [LeaderboardItem] {
        guard let url = filePath,FileManager.default.fileExists(atPath:url.path),let data = try? Data(contentsOf: url) else {
            return []
        }
        let list = try? JSONDecoder().decode([LeaderboardItem].self,from:data)
        return list ?? []
    }
}
