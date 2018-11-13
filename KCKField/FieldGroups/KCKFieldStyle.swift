//
//  KNetFieldStyle.swift
//  Kariyer.net
//
//  Created by Kemal Can Kaynak on 26.02.2017.
//  Copyright © 2018 Kariyer.net. All rights reserved.
//

import UIKit

public protocol KCKFieldStyle {
    var activeColor: UIColor { get }
    var inactiveColor: UIColor { get }
    var lineInactiveColor: UIColor { get }
    var errorColor: UIColor { get }
    var textInputFont: UIFont { get }
    var textInputFontColor: UIColor { get }
    var placeholderMinFontSize: CGFloat { get }
    var counterLabelFont: UIFont { get }
    var leftMargin: CGFloat { get }
    var topMargin: CGFloat { get }
    var rightMargin: CGFloat { get }
    var bottomMargin: CGFloat { get }
    var hintPositionOffsetY: CGFloat { get }
    var placeholderPositionOffsetY: CGFloat { get }
}

public struct KCKFieldDefaultStyle: KCKFieldStyle {
    
    public let activeColor = UIColor(hexString: "B3B8BC") ?? UIColor.lightGray
    public let inactiveColor = UIColor(hexString: "B3B8BC") ?? UIColor.lightGray
    public let lineInactiveColor = UIColor(hexString: "B3B8BC", alpha: 0.5) ?? UIColor.lightGray.withAlphaComponent(0.5)
    public let errorColor = UIColor(hexString: "D41846") ?? UIColor.red
    public let textInputFont = UIFont.systemFont(ofSize: 14)
    public let textInputFontColor = UIColor(hexString: "#5B5F62") ?? UIColor.darkGray
    public let placeholderMinFontSize: CGFloat = 11
    public let counterLabelFont = UIFont.systemFont(ofSize: 11)
    public let leftMargin: CGFloat = 0
    public let topMargin: CGFloat = 20
    public let rightMargin: CGFloat = 0
    public let bottomMargin: CGFloat = 5
    public let hintPositionOffsetY: CGFloat = 7
    public let placeholderPositionOffsetY: CGFloat = 0
    
    public init() {}
}

extension UIColor {
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var formatted = hexString.replacingOccurrences(of: "0x", with: "")
        formatted = formatted.replacingOccurrences(of: "#", with: "")
        guard let hex = Int(formatted, radix: 16) else { return nil }
        let red = CGFloat(CGFloat((hex & 0xFF0000) >> 16)/255.0)
        let green = CGFloat(CGFloat((hex & 0x00FF00) >> 8)/255.0)
        let blue = CGFloat(CGFloat((hex & 0x0000FF) >> 0)/255.0)
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
