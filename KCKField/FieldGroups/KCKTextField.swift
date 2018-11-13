//
//  KCKTextField.swift
//  Kariyer.net
//
//  Created by Kemal Can Kaynak on 12.01.2017.
//  Copyright © 2018 Kariyer.net. All rights reserved.
//

import UIKit

final internal class KCKTextField: UITextField {
    
    enum TextFieldType {
        case text
        case password
        case numeric
        case selection
    }
    
    private let defaultPadding: CGFloat = -10
    var rightViewPadding: CGFloat
    weak var textInputDelegate: TextInputDelegate?
    
    private var passwordButtonAction: (() -> ())?
    
    override init(frame: CGRect) {
        self.rightViewPadding = defaultPadding
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.rightViewPadding = defaultPadding
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        delegate = self
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.leftViewRect(forBounds: bounds).offsetBy(dx: 0, dy: 0)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.rightViewRect(forBounds: bounds).offsetBy(dx: rightViewPadding, dy: 0)
    }
    
    func add(passwordButton button: UIButton, action: @escaping (() -> ())) {
        let selector = #selector(disclosureButtonPressed)
        if passwordButtonAction != nil, let previousButton = rightView as? UIButton {
            previousButton.removeTarget(self, action: selector, for: .touchUpInside)
        }
        passwordButtonAction = action
        button.addTarget(self, action: selector, for: .touchUpInside)
        rightView = button
    }
    
    @objc private func disclosureButtonPressed() {
        passwordButtonAction?()
    }
    
    @objc private func textFieldDidChange() {
        textInputDelegate?.inputDidChange(textInput: self)
    }
}

extension KCKTextField: TextInput {
    
    var view: UIView { return self }
    
    var currentText: String? {
        get { return text }
        set { self.text = newValue }
    }
    
    var textAttributes: [NSAttributedString.Key: Any] {
        get { return typingAttributes ?? [:] }
        set { self.typingAttributes = textAttributes }
    }
    
    var fieldInputView: UIView? {
        get { return inputView }
        set { self.inputView = newValue }
    }

    var isEmpty: Bool {
        guard let fieldText = self.text else { return true }
        return fieldText.count == 0
    }

    var keyType: UIKeyboardType {
        get { return self.keyboardType }
        set { self.keyboardType = newValue }
    }

    var capitalType: UITextAutocapitalizationType {
        get { return self.autocapitalizationType }
        set { self.autocapitalizationType = newValue }
    }
}

extension KCKTextField: TextInputError {
    
    func configureErrorState(with message: String?) {
        placeholder = message
    }
    
    func removeErrorHintMessage() {
        placeholder = nil
    }
}

extension KCKTextField: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textInputDelegate?.inputDidBeginEditing(textInput: self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textInputDelegate?.inputDidEndEditing(textInput: self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textInputDelegate?.input(textInput: self, shouldChangeCharactersInRange: range, replacementString: string) ?? true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return textInputDelegate?.inputShouldBeginEditing(textInput: self) ?? true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return textInputDelegate?.inputShouldEndEditing(textInput: self) ?? true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textInputDelegate?.inputShouldReturn(textInput: self) ?? true
    }
}
