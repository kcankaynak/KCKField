//
//  KNetFieldConfigurator.swift
//  Kariyer.net
//
//  Created by Kemal Can Kaynak on 18.01.2018.
//  Copyright © 2018 Kariyer.net. All rights reserved.
//

import UIKit

public struct KCKFieldConfigurator {
    
    public enum inputType {
        case standard
        case picker
        case selection
        case multiline
        case password
    }
    
    static func configure(with type: inputType) -> TextInput {
        switch type {
        case .standard:
            return KCKFieldStandart.create()
        case .picker:
            return KCKFieldPicker.create()
        case .selection:
            return KCKFieldSelectable.create()
        case .multiline:
            return KCKFieldMultiLine.create()
        case .password:
            return KCKFieldPassword.create()
        }
    }
}

// MARK: - Raw Representable -

extension KCKFieldConfigurator.inputType: RawRepresentable {
    
    public typealias RawValue = Int
    
    public init?(rawValue: KCKFieldConfigurator.inputType.RawValue) {
        switch rawValue {
        case 0:
            self = .standard
        case 1:
            self = .picker
        case 2:
            self = .selection
        case 3:
            self = .multiline
        case 4:
            self = .password
        default:
            return nil
        }
    }
    
    public var rawValue: RawValue {
        switch self {
        case .standard:
            return 0
        case .picker:
            return 1
        case .selection:
            return 2
        case .multiline:
            return 3
        case .password:
            return 4
        }
    }
}

// MARK: - Standart Type -

private struct KCKFieldStandart {
    
    static func create() -> TextInput {
        let textField = KCKTextField()
        textField.clearButtonMode = .whileEditing
        return textField
    }
}

// MARK: - Picker Type -

private struct KCKFieldPicker {
    
    static func create() -> TextInput {
        let textField = KCKTextField()
        textField.rightView = UIImageView(image: #imageLiteral(resourceName: "arrow-down"))
        textField.rightViewMode = .always
        return textField
    }
}

// MARK: - Selectable Type -

private struct KCKFieldSelectable {
    
    static func create() -> TextInput {
        let textField = KCKTextField()
        textField.rightView = UIImageView(image: #imageLiteral(resourceName: "arrow-right"))
        textField.rightViewMode = .always
        textField.isUserInteractionEnabled = false
        return textField
    }
}

// MARK: - Multiline Type -

private struct KCKFieldMultiLine {
    
    static func create() -> TextInput {
        let textView = KCKTextView()
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        return textView
    }
}

// MARK: - Password Type -

private struct KCKFieldPassword {
    
    static func create() -> TextInput {
        
        let textField = KCKTextField()
        textField.rightViewMode = .whileEditing
        textField.isSecureTextEntry = true
        
        let showPasswordButton = UIButton(type: .custom)
        showPasswordButton.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20))
        showPasswordButton.setImage(#imageLiteral(resourceName: "passive_eye"), for: .normal)
        showPasswordButton.setImage(#imageLiteral(resourceName: "active_eye"), for: .selected)
        
        textField.add(passwordButton: showPasswordButton) {
            showPasswordButton.isSelected = !showPasswordButton.isSelected
            textField.resignFirstResponder()
            textField.isSecureTextEntry = !textField.isSecureTextEntry
            textField.becomeFirstResponder()
        }
        return textField
    }
}
