//
//  Constants.swift
//  Lego
//
//  Created by Shreyas Patankar on 3/23/20.
//  Copyright © 2020 Lego. All rights reserved.
//

import Foundation
import UIKit

struct LegoFSConsts {
    static let usersPrivColl = "users_priv"
    static let usersPubColl = "users_pub"
    static let chatsColl = "chats"
}

struct LegoColorConstants {
    static let darkBlue = simpleColor(red: 8, green: 65, blue: 92)
    static let red = simpleColor(red: 204, green: 41, blue: 54)
    static let pink = simpleColor(red: 235, green: 186, blue: 135)
    static let lightBlue = simpleColor(red: 56, green: 134, blue: 151)
    static let aqua = simpleColor(red: 181, green: 255, blue: 225)
    static let white = simpleColor(red: 255, green: 255, blue: 255)
    static let black = simpleColor(red: 0, green: 0, blue: 0)
}

struct LegoDefaultImages {
    static let rightArrowForButton = UIImage(named: "rightArrow.png")?.resizeImage(targetSize: CGSize(width: 35, height: 35))?.withTintColor(LegoColorConstants.darkBlue)
}

func simpleColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
    return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
}
