//
//  AppFont.swift
//  Dentist
//
//  Created by C100-105 on 10/04/19.
//  Copyright © 2019 C100-105. All rights reserved.
//

import Foundation
import UIKit

private let App_Font = "Montserrat-"

//App Custom Font Name
enum Enum_AppFont: String {
    case Regular
    case SemiBold
    case Medium
    case Light
    case ExtraBold
    case Bold
    case Black
}

public class AppFont {
    
    static let shared = AppFont()
    
    func setupAppFont() {
        let appFont = UIFont.systemFont(ofSize: 17).getAppFont()
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: appFont], for: .normal)
        
        UITextField.appearance().setAppFont = App_Font
        UILabel.appearance().setAppFont = App_Font
        UITextView.appearance().setAppFont = App_Font
    }
    
    ///MARK: Size According to Device
    /*
    func getFontSizeForDevice(_ currentFontSize: CGFloat) -> CGFloat {

        var fontsize = currentFontSize
        switch UIDevice().type {

        case .iPhoneSE, .iPhone5, .iPhone5S, .iPhone5C:
            fontsize += 0

        case .iPhone6, .iPhone6S, .iPhone7, .iPhone8,
             .iPhone6plus, .iPhone6Splus, .iPhone7plus, .iPhone8plus:
            fontsize += 1

        case .iPhoneX, .iPhoneXR, .iPhoneXS, .iPhoneXSMax:
            fontsize += 2

        default:
            fontsize += 3
        }

        return fontsize
    }
    */
    
    //MARK: - Font According to Device
    func getFontForDevice(style: Enum_AppFont, oldFont: UIFont) -> UIFont {
        let fontSize = oldFont.pointSize
        let sysFont = UIFont.systemFont(ofSize: fontSize)
        return sysFont.getAppFont()
    }
    
}

extension UILabel {
    @objc var setAppFont: String {
        get { return self.font.fontName }
        set {
            if !self.font.fontName.contains(App_Font) {
                self.font = font.getAppFont()
            }
        }
    }
}

extension UITextField {
    @objc var setAppFont : String {
        get { return self.font!.fontName }
        set {
            if let font = self.font, font.fontName.contains(App_Font) {
                self.font = font.getAppFont()
            }
        }
    }
}

extension UITextView {
    @objc var setAppFont : String {
        get { return self.font!.fontName }
        set {
            if let font = self.font, font.fontName.contains(App_Font) {
                self.font = font.getAppFont()
            }
        }
    }
}

extension UIFont {
    func getStyle() -> String {
        let oldSytle = self.fontDescriptor.postscriptName.split(separator: "-").last.asString()
        let style = Enum_AppFont(rawValue: oldSytle)
        
        var defaultStyle = ""
        
        if let style = style {
            defaultStyle = style.rawValue
        } else {
            switch oldSytle {
            case "Thin", "Ultra Light":
                defaultStyle = Enum_AppFont.Light.rawValue
                break
                
            case "Heavy":
                defaultStyle = Enum_AppFont.Black.rawValue
                break
                
            default:
                defaultStyle = Enum_AppFont.Regular.rawValue
                break
            }
        }
        return defaultStyle
    }
    
    func getAppFont() -> UIFont {
        let newFontName = App_Font+getStyle()
        return UIFont(name: newFontName, size: self.pointSize) ?? self
    }
}
