//
//  UIColor+SimpleRGB.swift
//  Reciplease
//
//  Created by Greg-Mini on 29/12/2022.
//

import UIKit

extension UIColor {
    static func simpleRGB(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}
