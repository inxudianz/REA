//
//  FontHelper.swift
//  Creativ
//
//  Created by Owen Prasetya on 21/11/19.
//  Copyright © 2019 William Inx. All rights reserved.
//

import Foundation
import UIKit

class CustomFont {
    enum fontType {
        case Black, BlackItalic
        case Bold, BoldItalic
        case Light, LightItalic
        case Italic, Regular
    }
    
    func printAllFont() {
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family : \(family) Font names: \(names)")
        }
    }
    
    func getCustomFontType(type: fontType, size: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: "Merriweather-\(type)", size: size) else {
            fatalError("""
                    Failed to load Merriweather-Black font.
                    Please include it in the project or make sure the font name is correct.
                    """)
        }
        return customFont
    }
}
