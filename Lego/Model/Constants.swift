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
    static let eventsColl = "events"
    static let eventsStorage = "events"
    static let imageSizeLimit = Int64.max
}

struct LegoColorConstants {
    static let darkBlue = simpleColor(red: 8, green: 65, blue: 92)
    static let red = simpleColor(red: 204, green: 41, blue: 54)
    static let pink = simpleColor(red: 235, green: 186, blue: 135)
    static let lightBlue = simpleColor(red: 56, green: 134, blue: 151)
    static let aqua = simpleColor(red: 181, green: 255, blue: 225)
    static let white = UIColor.white // simpleColor(red: 255, green: 255, blue: 255)
    static let gray = UIColor(red: 0.541, green: 0.494, blue: 0.604, alpha: 1)
    static let black = simpleColor(red: 0, green: 0, blue: 0)
    static let purple = UIColor(red: 0.447, green: 0.235, blue: 0.922, alpha: 1)
    static let backgroundColor = UIColor(red: 0.098, green: 0.094, blue: 0.122, alpha: 1)
    static let buttonColor = UIColor(red: 0.141, green: 0.125, blue: 0.165, alpha: 1)
    static let subButtonColor = UIColor(red: 0.223, green: 0.199, blue: 0.258, alpha: 1)
}

struct LegoMapConstants {
    static let markerSize = 30
    static let nearbyEventsRadius: Double = 60
}

struct LegoFonts {
    static let SFProTextBold = UIFont(name: "SF-Pro-Text-Bold", size: 17)
    static let SFProTextMedium = UIFont(name: "SF-Pro-Text-Medium", size: 17)
    static let SFProDisplayBold = UIFont(name: "SF-Pro-Display-Bold", size: 17)
}

struct LegoDefaultImages {
    static let rightArrowForButton = UIImage(named: "rightArrow.png")?.resizeImage(targetSize: CGSize(width: 35, height: 35))?.withTintColor(LegoColorConstants.darkBlue)
}

func simpleColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
    return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
}
