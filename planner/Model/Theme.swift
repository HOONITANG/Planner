//
//  UIFont.swift
//  planner
//
//  Created by Taehoon Kim on 2021/09/23.
//

import Foundation
import UIKit

extension UIFont {
    static func openSansBold(size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Bold", size: size) ?? .systemFont(ofSize: size)
    }
    
    static func openSansExtraBold(size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-ExtraBold", size: size) ?? .systemFont(ofSize: size)
    }
    static func openSansItalic(size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Italic", size: size) ?? .systemFont(ofSize: size)
    }
    static func openSansLight(size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Light", size: size) ?? .systemFont(ofSize: size)
    }
    static func openSansRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Regular", size: size) ?? .systemFont(ofSize: size)
    }
    static func openSansSemiBold(size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-SemiBold", size: size) ?? .systemFont(ofSize: size)
    }
    static func montserratBlack(size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Black", size: size) ?? .systemFont(ofSize: size)
    }
    static func montserratBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Bold", size: size) ?? .systemFont(ofSize: size)
    }
    static func montserratExtraBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-ExtraBold", size: size) ?? .systemFont(ofSize: size)
    }
    static func montserratExtraLight(size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-ExtraLight", size: size) ?? .systemFont(ofSize: size)
    }
    static func montserratLight(size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Light", size: size) ?? .systemFont(ofSize: size)
    }
    static func montserratMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Medium", size: size) ?? .systemFont(ofSize: size)
    }
    static func montserratRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Regular", size: size) ?? .systemFont(ofSize: size)
    }
    static func montserratSemiBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-SemiBold", size: size) ?? .systemFont(ofSize: size)
    }
    static func montserratThin(size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Thin", size: size) ?? .systemFont(ofSize: size)
    }
}


// Hex Code Color을 사용하게 하는 함수
// let color = UIColor(rgb: 0xFFFFFF)
// let color = UIColor(rgb: 0xFFFFFF).withAlphaComponent(1.0)
// let color2 = UIColor(argb: 0xFFFFFFFF)

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, a: Int = 0xFF) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
    
    convenience init(rgb: Int) {
        self.init(
            red:(rgb >> 16) & 0xFF,
            green:(rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    // let's suppose alpha is the first component (ARGB)

      convenience init(argb: Int) {
          self.init(
              red: (argb >> 16) & 0xFF,
              green: (argb >> 8) & 0xFF,
              blue: argb & 0xFF,
              a: (argb >> 24) & 0xFF
          )
      }
}
