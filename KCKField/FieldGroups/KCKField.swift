//
//  KNetField.swift
//  Kariyer.net
//
//  Created by Kemal Can Kaynak on 13.01.2017.
//  Copyright © 2018 Kariyer.net. All rights reserved.
//

import UIKit

@objc public protocol KCKFieldDelegate: class {
    @objc optional func fieldDidBeginEditing(_ field: KCKField)
    @objc optional func fieldDidEndEditing(_ field: KCKField)
    @objc optional func fieldDidChange(_ field: KCKField)
    @objc optional func field(_ field: KCKField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    @objc optional func fieldShouldBeginEditing(_ field: KCKField) -> Bool
    @objc optional func fieldShouldEndEditing(_ field: KCKField) -> Bool
    @objc optional func fieldShouldReturn(_ field: KCKField) -> Bool
}

public class KCKField: UIControl {
    
    public var tapAction: (() -> ())?
    public weak var delegate: KCKFieldDelegate?
    public private(set) var isActive = false
    
    // 'Default' field type is 'standart'
    // 0 -> standard, 1 -> picker, 2 -> selection
    // 3 -> multiline, 4 -> password
    @IBInspectable public var fieldType: Int {
        get { return self.type.rawValue }
        set { self.type = KCKFieldConfigurator.inputType(rawValue: newValue) ?? .standard }
    }
    
    public var type: KCKFieldConfigurator.inputType = .standard {
        didSet {
            configureType()
        }
    }
    
    @IBInspectable public var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    public var style: KCKFieldStyle = KCKFieldDefaultStyle() {
        didSet {
            configureStyle()
        }
    }
    
    public var fieldView: UIView {
        return self.textInput.view
    }
    
    public var text: String? {
        get {
            return textInput.currentText
        }
        set {
            if !textInput.view.isFirstResponder {
                (newValue != nil) ? configurePlaceholderAsInactiveHint() : configurePlaceholderAsDefault()
            }
            textInput.currentText = newValue
        }
    }
    
    public var fieldInputView: UIView? {
        didSet {
            textInput.fieldInputView = fieldInputView
        }
    }

    public var isEmpty: Bool {
        return textInput.isEmpty
    }

    public var keyboardType: UIKeyboardType {
        get {
            return textInput.keyType
        }
        set {
            textInput.keyType = newValue
        }
    }

    public var autocapitalizationType: UITextAutocapitalizationType {
        get {
            return textInput.capitalType
        }
        set {
            textInput.capitalType = newValue
        }
    }
    
    @IBInspectable public var maxCharacter: Int = Int.max {
        didSet {
            maximumCharacter = maxCharacter
        }
    }
    
    @IBInspectable public var showCounterLabel: Bool = false {
        didSet {
            if showCounterLabel {
                showCharacterCounterLabel()
            }
        }
    }
    
    private let lineView = KCKFieldLineView()
    private let placeholderLabel = UILabel()
    private var placeholderSize: CGSize = .zero
    private let counterLabel = UILabel()
    private let lineWidth: CGFloat = 1
    private let counterLabelRightMargin: CGFloat = 0
    private let counterLabelTopMargin: CGFloat = 5
    
    private var isResigningResponder = false
    private var isPlaceholderAsHint = false
    private var textInput: TextInput!
    private var placeholderErrorText: String?
    private var lineToBottomConstraint: NSLayoutConstraint!
    private final var maximumCharacter: Int?
    private final let transactionAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCommonElements()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCommonElements()
    }
}

// MARK: - Basic Setup -

extension KCKField {
    
    private func setupCommonElements() {
        addLine()
        addPlaceHolder()
        addTapGestureRecognizer()
        addTextInput()
    }
    
    private var placeholderPosition: CGPoint {
        let hintPosition = CGPoint(x: style.leftMargin, y: style.hintPositionOffsetY)
        let defaultPosition = CGPoint(x: style.leftMargin, y: style.topMargin + style.placeholderPositionOffsetY)
        return isPlaceholderAsHint ? hintPosition : defaultPosition
    }
    
    private func layoutPlaceholderLayer() {
        let frameHeightCorrectionFactor: CGFloat = 1.2

        var maxWidth: CGFloat = 0.0

        switch type {
        case .picker, .selection, .password:
            maxWidth = bounds.width - 25
        default:
            maxWidth = bounds.width
        }

        placeholderLabel.frame = CGRect(origin: placeholderPosition, size: CGSize(width: maxWidth, height: style.textInputFont.pointSize * frameHeightCorrectionFactor))
        placeholderSize = placeholderLabel.frame.size
    }
    
    private func addLineViewConstraints() {
        pinLeading(toLeading: lineView, constant: style.leftMargin)
        pinTrailing(toTrailing: lineView, constant: style.rightMargin)
        lineView.setHeight(to: 1.5)
        pinBottom(toBottom: lineView, constant: 0)
    }
    
    private func addTextInputConstraints() {
        pinLeading(toLeading: textInput.view, constant: style.leftMargin)
        pinTrailing(toTrailing: textInput.view, constant: style.rightMargin)
        pinTop(toTop: textInput.view, constant: style.topMargin)
        textInput.view.pinBottom(toTop: lineView, constant: style.bottomMargin)
    }
    
    private func addLine() {
        lineView.defaultColor = style.lineInactiveColor
        lineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lineView)
    }
    
    private func addPlaceHolder() {

        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.layer.masksToBounds = false
        placeholderLabel.text = placeholder
        placeholderLabel.font = style.textInputFont.withSize(style.textInputFont.pointSize)
        placeholderLabel.backgroundColor = .clear
        placeholderLabel.textAlignment = .left
        placeholderLabel.textColor = style.inactiveColor
        placeholderLabel.lineBreakMode = .byTruncatingTail
        layoutPlaceholderLayer()
        addSubview(placeholderLabel)
    }
    
    private func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped(sender:)))
        addGestureRecognizer(tap)
    }
    
    private func addTextInput() {
        textInput = KCKFieldConfigurator.configure(with: type)
        textInput.textInputDelegate = self
        textInput.view.tintColor = style.activeColor
        textInput.textColor = style.textInputFontColor
        textInput.font = style.textInputFont
        textInput.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textInput.view)
        invalidateIntrinsicContentSize()
    }
    
    public func updateCounter() {
        guard let counterText = counterLabel.text else { return }
        let components = counterText.components(separatedBy: "/")
        let count = (text != nil) ? text!.count : 0
        counterLabel.text = "\(count)/\(components[1])"
    }
}

// MARK: - Overridable Methods -

extension KCKField {
    
    public override var intrinsicContentSize: CGSize {
        let normalHeight = textInput.view.intrinsicContentSize.height
        return CGSize(width: UIView.noIntrinsicMetric, height: normalHeight + style.topMargin + style.bottomMargin)
    }
    
    public override func updateConstraints() {
        addLineViewConstraints()
        addTextInputConstraints()
        super.updateConstraints()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutPlaceholderLayer()
    }
    
    override public func becomeFirstResponder() -> Bool {
        isActive = true
        textInput.view.becomeFirstResponder()
        counterLabel.textColor = style.activeColor
        placeholderErrorText = nil
        configurePlaceholderAsActiveHint()
        return true
    }
    
    override public func resignFirstResponder() -> Bool {
        guard !isResigningResponder else { return true }
        isActive = false
        isResigningResponder = true
        textInput.view.resignFirstResponder()
        isResigningResponder = false
        counterLabel.textColor = style.inactiveColor
        
        if let textInputError = textInput as? TextInputError {
            textInputError.removeErrorHintMessage()
        }
        
        if placeholderErrorText == nil {
            animateToInactiveState()
        }
        return true
    }
    
    public override var canResignFirstResponder: Bool {
        return textInput.view.canResignFirstResponder
    }
    
    public override var canBecomeFirstResponder: Bool {
        guard !isResigningResponder else { return false }
        return textInput.view.canBecomeFirstResponder
    }
}

// MARK: - Field States -

extension KCKField {
    
    private func configurePlaceholderAsActiveHint() {
        isPlaceholderAsHint = true
        animatePlaceholder(withTransform: CGAffineTransform(scaleX: 0.8, y: 0.8),
                           textColor: style.activeColor,
                           text: placeholder)
        lineView.fillLine(with: style.activeColor)
    }
    
    private func configurePlaceholderAsInactiveHint() {
        isPlaceholderAsHint = true
        animatePlaceholder(withTransform: CGAffineTransform(scaleX: 0.8, y: 0.8),
                           textColor: style.inactiveColor,
                           text: placeholder)
        lineView.animateToInitialState()
    }
    
    private func configurePlaceholderAsDefault() {
        isPlaceholderAsHint = false
        animatePlaceholder(withTransform: CGAffineTransform.identity,
                           textColor: style.inactiveColor,
                           text: placeholder)
        lineView.animateToInitialState()
    }
    
    private func configurePlaceholderAsErrorHint() {
        isPlaceholderAsHint = true
        animatePlaceholder(withTransform: CGAffineTransform(scaleX: 0.8, y: 0.8),
                           textColor: style.errorColor,
                           text: placeholderErrorText)
        lineView.fillLine(with: style.errorColor)
    }

    private func animatePlaceholder(withTransform transform: CGAffineTransform, textColor: UIColor, text: String?) {
        UIView.animate(withDuration: 0.2, animations: {
            self.placeholderLabel.transform = transform
            self.placeholderLabel.textColor = textColor
            self.placeholderLabel.text = text
            self.placeholderLabel.frame = CGRect(origin: self.placeholderPosition,
                                                 size: transform == .identity ? self.placeholderSize : CGSize(width: self.placeholderLabel.frame.size.width + 25, height: self.placeholderLabel.frame.size.height))
        })
    }
    
    private func animateToInactiveState() {
        guard let text = textInput.currentText, !text.isEmpty else {
            configurePlaceholderAsDefault()
            return
        }
        configurePlaceholderAsInactiveHint()
    }
}

// MARK: - Configure Style -

extension KCKField {
    
    private func configureType() {
        textInput.view.removeFromSuperview()
        addTextInput()
    }
    
    private func configureStyle() {
        styleDidChange()
        isActive ? configurePlaceholderAsActiveHint() : isPlaceholderAsHint ? configurePlaceholderAsInactiveHint() : configurePlaceholderAsDefault()
    }
    
    private func styleDidChange() {
        lineView.defaultColor = style.lineInactiveColor
        placeholderLabel.textColor = style.inactiveColor
        placeholderLabel.font = style.textInputFont.withSize(style.textInputFont.pointSize)

        layoutPlaceholderLayer()
        textInput.view.tintColor = style.activeColor
        textInput.textColor = style.textInputFontColor
        textInput.font = style.textInputFont
        invalidateIntrinsicContentSize()
        layoutIfNeeded()
    }
}

// MARK: - KNetField -

extension KCKField {
    
    @objc private func viewTapped(sender: UIGestureRecognizer) {
        if let tapAction = tapAction {
            tapAction()
        } else {
            _ = becomeFirstResponder()
        }
    }
}

// MARK: - Character Counter Label -

extension KCKField {
    
    private final func showCharacterCounterLabel() {
        
        let count = (text != nil) ? text!.count : 0
        counterLabel.text = "\(count)/\(maxCharacter)"
        counterLabel.textColor = isActive ? style.activeColor : style.inactiveColor
        counterLabel.font = style.counterLabelFont
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(counterLabel)
        
        addCharacterCounterConstraints()
        invalidateIntrinsicContentSize()
    }
    
    private func addCharacterCounterConstraints() {
        lineView.pinBottom(toTop: counterLabel, constant: counterLabelTopMargin)
        pinTrailing(toTrailing: counterLabel, constant: counterLabelRightMargin)
    }
    
    public func removeCharacterCounterLabel() {
        counterLabel.removeConstraints(counterLabel.constraints)
        counterLabel.removeFromSuperview()
        lineToBottomConstraint.constant = 0
        invalidateIntrinsicContentSize()
    }
}

// MARK: - Error States -

extension KCKField {
    
    public func show(error errorMessage: String, placeholderText: String? = nil) {
        placeholderErrorText = errorMessage
        if let textInput = textInput as? TextInputError {
            textInput.configureErrorState(with: placeholderText)
        }
        configurePlaceholderAsErrorHint()
    }
    
    public func clearError() {
        placeholderErrorText = nil
        if let textInputError = textInput as? TextInputError {
            textInputError.removeErrorHintMessage()
        }
        if isActive {
            configurePlaceholderAsActiveHint()
        } else {
            animateToInactiveState()
        }
    }
}

// MARK: - Text Input Delegate -

extension KCKField: TextInputDelegate {
    
    public func inputDidBeginEditing(textInput: TextInput) {
        _ = becomeFirstResponder()
        delegate?.fieldDidBeginEditing?(self)
    }
    
    public func inputDidEndEditing(textInput: TextInput) {
        _ = resignFirstResponder()
        delegate?.fieldDidEndEditing?(self)
    }
    
    public func inputDidChange(textInput: TextInput) {
        updateCounter()
        delegate?.fieldDidChange?(self)
    }
    
    public func input(textInput: TextInput, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let maximumCharacter = maximumCharacter, let text = textInput.currentText {
            let finalLength = text.count + string.count - range.length
            return finalLength <= maximumCharacter
        }
        return delegate?.field?(self, shouldChangeCharactersInRange: range, replacementString: string) ?? true
    }
    
    public func inputShouldBeginEditing(textInput: TextInput) -> Bool {
        return delegate?.fieldShouldBeginEditing?(self) ?? true
    }
    
    public func inputShouldEndEditing(textInput: TextInput) -> Bool {
        return delegate?.fieldShouldEndEditing?(self) ?? true
    }
    
    public func inputShouldReturn(textInput: TextInput) -> Bool {
        return delegate?.fieldShouldReturn?(self) ?? true
    }
}

// MARK: - Animate Constraints -

extension UIView {
    
    func transactionAnimation(with duration: CFTimeInterval, timingFuncion: CAMediaTimingFunction, animations: () -> ()) {
        CATransaction.begin()
        CATransaction.disableActions()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(timingFuncion)
        animations()
        CATransaction.commit()
    }
    
    func pinLeading(toLeading view: UIView, constant: CGFloat) {
        NSLayoutConstraint(item: view,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: self,
                           attribute: .leading,
                           multiplier: 1.0,
                           constant: constant).isActive = true
    }
    
    func pinTrailing(toTrailing view: UIView, constant: CGFloat) {
        NSLayoutConstraint(item: view,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: self,
                           attribute: .trailing,
                           multiplier: 1.0,
                           constant: -constant).isActive = true
    }
    
    func pinTop(toTop view: UIView, constant: CGFloat) {
        NSLayoutConstraint(item: view,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: self,
                           attribute: .top,
                           multiplier: 1.0,
                           constant: constant).isActive = true
    }
    
    func pinBottom(toBottom view: UIView, constant: CGFloat) {
        NSLayoutConstraint(item: view,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self,
                           attribute: .bottom,
                           multiplier: 1.0,
                           constant: -constant).isActive = true
    }
    
    func pinBottom(toTop view: UIView, constant: CGFloat) {
        NSLayoutConstraint(item: self,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .top,
                           multiplier: 1.0,
                           constant: -constant).isActive = true
    }
    
    func setHeight(to constant: CGFloat) {
        NSLayoutConstraint(item: self,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1.5,
                           constant: constant).isActive = true
    }
}

public protocol TextInput {
    var view: UIView { get }
    var fieldInputView: UIView? { get set }
    var currentText: String? { get set }
    var font: UIFont? { get set }
    var textColor: UIColor? { get set }
    var isEmpty: Bool { get }
    var keyType: UIKeyboardType { get set }
    var capitalType: UITextAutocapitalizationType { get set }
    var textInputDelegate: TextInputDelegate? { get set }
}

public protocol TextInputDelegate: class {
    func inputDidBeginEditing(textInput: TextInput)
    func inputDidEndEditing(textInput: TextInput)
    func inputDidChange(textInput: TextInput)
    func input(textInput: TextInput, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    func inputShouldBeginEditing(textInput: TextInput) -> Bool
    func inputShouldEndEditing(textInput: TextInput) -> Bool
    func inputShouldReturn(textInput: TextInput) -> Bool
}

public protocol TextInputError {
    func configureErrorState(with message: String?)
    func removeErrorHintMessage()
}
