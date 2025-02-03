//
//  LeaderboardViewModel.swift
//  demoTicTac
//
//  Created by PavelMac on 2/02/2025.
//  Copyright © 2025 Monitoreal – Smart Monitoring LLC. All rights reserved.
//

import UIKit

class LeaderboardCell: UITableViewCell {
    
    @IBOutlet var positionIdLbl: UILabel!
    @IBOutlet var gameTimeLbl: UILabel!
    @IBOutlet var waysCountLbl: UILabel!
    @IBOutlet var userFullNameLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .gray
        self.positionIdLbl.textColor = .white
        self.gameTimeLbl.textColor = .white
        self.waysCountLbl.textColor = .white
        self.userFullNameLbl.textColor = .white

        prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.positionIdLbl.text =  nil
        self.gameTimeLbl.text =  nil
        self.waysCountLbl.text =  nil
        self.userFullNameLbl.text =  nil
    }
    
    func configure(with board: LeaderboardViewModel) {
        self.positionIdLbl.text = board.positionId
        self.gameTimeLbl.text = board.gameTime
        self.waysCountLbl.text = board.waysCount
        self.userFullNameLbl.text = board.userFullName
    }
}
