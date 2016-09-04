//
//  GameModel.swift
//  Messages
//
//  Created by lisk@uuzu.com on 2016/9/4.
//  Copyright © 2016年 MOB. All rights reserved.
//

import Foundation
import Messages

struct GameModel {
    /// The cell locations of the ships
    let shipLocations: [Int]
    /// Whether the game has been completed or is still in progress
    var isComplete: Bool
}

