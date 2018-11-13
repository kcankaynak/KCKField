//
//  KCKTextView.swift
//  Kariyer.net
//
//  Created by Kemal Can Kaynak on 18.02.2017.
//  Copyright © 2018 Kariyer.net. All rights reserved.
//

import UIKit

final internal class KCKTextView: UITextView {
    
    weak var textInputDelegate: TextInputDelegate?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        delegate = self
        textContainerInset = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        textContainer.lineFragmentPadding = 0
    }
    
    override func resignFirstResponder() -> Bool {
        return super.resignFirstResponder()
    }
}

// MARK: - Text Input Setup -

extension KCKTextView: TextInput {
    
    var view: UIView { return self }
    
    var currentText: String? {
        get { return text }
        set { self.text = newValue }
    }
    
    var textAttributes: [NSAttributedString.Key: Any] {
        get { return typingAttributes }
        set { self.typingAttributes = textAttributes }
    }
    
    var fieldInputView: UIView? {
        get { return inputView }
        set { self.inputView = newValue }
    }

    var isEmpty: Bool {
        return text.count == 0
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

// MARK: - UITextView Delegate -

extension KCKTextView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textInputDelegate?.inputDidBeginEditing(textInput: self)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textInputDelegate?.inputDidEndEditing(textInput: self)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textInputDelegate?.inputDidChange(textInput: self)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textInputDelegate?.input(textInput: self, shouldChangeCharactersInRange: range, replacementString: text) ?? true
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return textInputDelegate?.inputShouldBeginEditing(textInput: self) ?? true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return textInputDelegate?.inputShouldEndEditing(textInput: self) ?? true
    }
}

