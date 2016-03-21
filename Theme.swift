//
//  Theme.swift
//  SmartChannel
//
//  Created by Jerry on 3/6/16.
//  Copyright © 2016 SmartChannel. All rights reserved.
//

import UIKit

struct Theme {
    enum Colors {
        case BackgroundColor
        case DarkBackgroundColor
        case LightBackgroundColor
        case HighlightColor
        case HighlightLightColor
        case LightButtonColor
        case PlayColor
        case EditColor
        case DeleteColor
        case SeparatorColor
        
        var color: UIColor{
            switch self {
            case .BackgroundColor: return UIColor(red: 32/255, green: 34/255, blue: 43/255, alpha: 1)
            case .DarkBackgroundColor: return UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1)
            case .LightBackgroundColor: return UIColor(red: 54/255, green: 56/255, blue: 67/255, alpha: 1)
            case .HighlightColor: return UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
            case .HighlightLightColor: return UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 0.5)
            case .LightButtonColor: return UIColor(red: 53/255, green: 57/255, blue: 73/255, alpha: 1)
            case .PlayColor: return UIColor(red: 164/255, green: 179/255, blue: 112/255, alpha: 1)
            case .EditColor: return UIColor(red: 113/255, green: 154/255, blue: 175/255, alpha: 1)
            case .DeleteColor: return UIColor(red: 225/255, green: 79/255, blue: 79/255, alpha: 1)
            case .SeparatorColor: return UIColor(red: 67/255, green: 71/255, blue: 86/255, alpha: 1)
            }
        }
    }
    
    enum Fonts {
        case TitleTypeFace
        case TitleThinTypeFace
        case NormalTypeFace
        case LightNormalTypeFace
        case BoldNormalTypeFace

        var font: UIFont {
            switch self {
            case .TitleThinTypeFace: return UIFont.systemFontOfSize(24, weight: UIFontWeightThin)
            case .TitleTypeFace: return UIFont.systemFontOfSize(24, weight: UIFontWeightRegular)
            case .NormalTypeFace: return UIFont.systemFontOfSize(17, weight: UIFontWeightRegular)
            case .LightNormalTypeFace: return UIFont.systemFontOfSize(17, weight: UIFontWeightLight)
            case .BoldNormalTypeFace: return UIFont.systemFontOfSize(17, weight: UIFontWeightBold)
            }
        }
    }

    static func applyTheme() {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().barTintColor = Colors.BackgroundColor.color
        UINavigationBar.appearance().tintColor = Colors.HighlightColor.color
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Colors.HighlightColor.color]
    }
}
