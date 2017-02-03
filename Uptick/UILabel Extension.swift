//
//  UILabel Extension.swift
//  Uptick
//
//  Created by Chris Kong on 1/19/17.
//  Copyright © 2017 Chris Kong. All rights reserved.
//

import Foundation
import UIKit

public extension UILabel {
    func addCharactersSpacing(spacing: CGFloat, text: String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSMakeRange(0, text.characters.count))
        self.attributedText = attributedString
    }
}
