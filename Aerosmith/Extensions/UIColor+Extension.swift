//
//  UIColor+extension.swift
//  Aerosmith
//
//  Created by Nicolas Lebrun on 20/01/2018.
//  Copyright © 2018 Nicolas Lebrun. All rights reserved.
//
import UIKit

extension UIColor {
    
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }

    class var customRed: UIColor { return UIColor(hex: 0xE14F34) }
    class var customGreen: UIColor { return UIColor(hex: 0x33EA9D) }
    
    func toHex() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}
