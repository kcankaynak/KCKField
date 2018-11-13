//
//  KCKFieldLineView.swift
//  Kariyer.net
//
//  Created by Kemal Can Kaynak on 29.01.2017.
//  Copyright © 2018 Kariyer.net. All rights reserved.
//

import UIKit

public final class KCKFieldLineView: UIView {

    enum fillDirection {
        case left
        case right
    }
    
    private let lineLayer = CAShapeLayer()
    final var animationDuration: Double = 0.25
    
    final var defaultColor = UIColor(hexString: "B3B8BC")! {
        didSet {
            backgroundColor = defaultColor
        }
    }
    
    final var lineDirection: fillDirection = .left {
        didSet {
            updatePath()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = defaultColor
        addLine()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        lineLayer.frame = bounds
        lineLayer.lineWidth = bounds.height
        updatePath()
    }
}

// MARK: - Add Line -

extension KCKFieldLineView {
    
    private func addLine() {
        lineLayer.frame = bounds
        lineLayer.backgroundColor = UIColor.clear.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = defaultColor.cgColor
        lineLayer.lineWidth = bounds.height
        updatePath()
        lineLayer.strokeEnd = 0
        layer.addSublayer(lineLayer)
    }
}

// MARK: - Fill Line -

extension KCKFieldLineView {
    
    func fillLine(with color: UIColor) {
        if lineLayer.strokeEnd == 1 {
            backgroundColor = UIColor(cgColor: lineLayer.strokeColor ?? defaultColor.cgColor)
        }
        lineLayer.strokeColor = color.cgColor
        lineLayer.strokeEnd = 0
        animateLine(to: 1.0)
    }
}

// MARK: - Set Line Path -

extension KCKFieldLineView {
    
    private func updatePath() {
        lineLayer.path = linePath()
    }
    
    private func linePath() -> CGPath {
        
        let path = UIBezierPath()
        let initialPoint = CGPoint(x: 0, y: bounds.midY)
        let finalPoint = CGPoint(x: bounds.width, y: bounds.midY)
        
        switch lineDirection {
        case .left:
            path.move(to: initialPoint)
            path.addLine(to: finalPoint)
        case .right:
            path.move(to: finalPoint)
            path.addLine(to: initialPoint)
        }
        return path.cgPath
    }
}

// MARK: - Animate Line -

extension KCKFieldLineView {
    
    func animateToInitialState() {
        backgroundColor = defaultColor
        animateLine(to: 0.0)
    }
    
    private func animateLine(to value: CGFloat) {
        let function = CAMediaTimingFunction(name: .easeInEaseOut)
        transactionAnimation(with: animationDuration, timingFuncion: function) {
            self.lineLayer.strokeEnd = value
        }
    }
}
