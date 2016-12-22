//
//  UIColor+HexColors.swift
//  Uptick
//
//  Created by Chris Kong on 12/19/16.
//  Copyright © 2016 Chris Kong. All rights reserved.
//

import UIKit

public extension UIColor {
    public class func colorWithHex(hex: String) -> UIColor? {
        
        let hash = hex.replacingOccurrences(of: "#", with: "")
        let hexColor = hash.substring(from: hash.startIndex)
        return colorFromHex(hexColor: normalizeHexColorString(hexColor: hexColor)!)
    }
    
    //  MARK: Private methods
    
    private class func colorFromHex(hexColor: String) -> UIColor? {
        
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let alpha: CGFloat
        
        var color: UIColor? = nil
        
        if hexColor.characters.count == 8 {
            
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            
            if scanner.scanHexInt64(&hexNumber) {
                red = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                green = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                blue = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                alpha = CGFloat(hexNumber & 0x000000ff) / 255
                
                color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            }
        }
        
        return color
    }
    
    private class func normalizeHexColorString(hexColor: String) -> String? {
        if (hexColor.characters.count == 8) {
            return hexColor
        }
        
        if (hexColor.characters.count == 6) {
            return String(format: "%@ff", hexColor)
        }
        
        if (hexColor.characters.count == 3) {
            
            let redRange: Range<String.Index> = hexColor.index(hexColor.startIndex, offsetBy: 0)..<hexColor.index(hexColor.startIndex, offsetBy:1)
            
            let redString: String = String(format: "%@%@", hexColor.substring(with:redRange), hexColor.substring(with:redRange))
            
            let greenRange: Range<String.Index> = hexColor.index(hexColor.startIndex, offsetBy: 1)..<hexColor.index(hexColor.startIndex, offsetBy: 2)
            
            let greenString: String = String(format: "%@%@", hexColor.substring(with:greenRange), hexColor.substring(with:greenRange))
            
            let blueRange: Range<String.Index> = hexColor.index(hexColor.startIndex, offsetBy: 2)..<hexColor.index(hexColor.startIndex, offsetBy: 3)
            
            let blueString: String = String(format: "%@%@", hexColor.substring(with:blueRange), hexColor.substring(with:blueRange))
            
            let hex: String = String(format: "%@%@%@", redString, greenString, blueString)
            
            return hex
        }
        
        assert(true)
        return nil
    }
}
