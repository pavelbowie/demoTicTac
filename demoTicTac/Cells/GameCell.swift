//
//  GameCell.swift
//  demoTicTac
//
//  Created by PavelMac on 2/02/2025.
//  Copyright © 2025 Monitoreal – Smart Monitoring LLC. All rights reserved.
//

import UIKit

extension State {
    func stateImage() -> UIImage? {
        var image: UIImage?
        switch self {
        case .circleSelected:
            image = #imageLiteral(resourceName: "iconCross")
        case .crossSelected:
            image = #imageLiteral(resourceName: "iconRound")
        default:
            break
        }
        return image
    }
}

public class GameCell: UIImageView {
    
    var state = State.undefined {
        didSet {
            self.unHighlight()
            self.image  = state.stateImage()
        }
    }
    
    var position = GameBoardPosition(column:-1, row:-1)
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentMode = .scaleAspectFit
        self.isUserInteractionEnabled  = true
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = false
    }
    
    func highlight() {
        self.backgroundColor = .white
    }

    func unHighlight() {
        self.backgroundColor = .clear
    }
}
