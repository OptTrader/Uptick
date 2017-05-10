//
//  String Extension.swift
//  Uptick
//
//  Created by Chris Kong on 1/24/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func encodeUrl() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
    
    func decodeUrl() -> String
    {
        return self.removingPercentEncoding!
    }
    
    func removeSlashCharacter() -> String {
        return self.replacingOccurrences(of: "/", with: "")
    }
    
    static func formatDefaultLabel(text: String, spacing: CGFloat) -> NSMutableAttributedString {
        let length = text.characters.count
        let attributedPriceString = NSMutableAttributedString(string: text)
        attributedPriceString.addAttribute(NSKernAttributeName, value: spacing, range: NSMakeRange(0, length))
        return attributedPriceString
    }
    
    static func formatPriceLabel(text: String, priceSpacing: CGFloat, decimalSpacing: CGFloat) -> NSMutableAttributedString {
        
        let length = text.characters.count
        
        let attributedPriceString = NSMutableAttributedString(string: text)
        attributedPriceString.addAttribute(NSKernAttributeName, value: priceSpacing, range: NSMakeRange(0, length - 2))
        attributedPriceString.addAttribute(NSKernAttributeName, value: decimalSpacing, range: NSMakeRange(length - 2, 2))
        attributedPriceString.addAttribute(NSFontAttributeName, value: Font.smallText, range: NSMakeRange(length - 2, 2))
        
        return attributedPriceString
    }
    
    static func formatMarketCapLabel(text: String, numberSpacing: CGFloat, textSpacing: CGFloat) -> NSMutableAttributedString {
        let length = text.characters.count
        let attributedPriceString = NSMutableAttributedString(string: text)
        
        attributedPriceString.addAttribute(NSKernAttributeName, value: numberSpacing, range: NSMakeRange(0, length - 3))
        attributedPriceString.addAttribute(NSKernAttributeName, value: textSpacing, range: NSMakeRange(length - 3, 3))
        attributedPriceString.addAttribute(NSFontAttributeName, value: Font.smallText, range: NSMakeRange(length - 3, 3))
        
        return attributedPriceString
    }

}
