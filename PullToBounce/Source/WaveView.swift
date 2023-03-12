//
//  WaveView.swift
//  PullToBounce
//
//  Created by Takuya Okamoto on 2015/08/11.
//  Copyright (c) 2015年 Uniface. All rights reserved.
//

import UIKit

class WaveView: UIView {
    @objc var didEndPull: () -> Void = {}
    @objc private var waveLayer: CAShapeLayer
    @objc private let bounceDuration: CFTimeInterval
    @objc private let color: UIColor
    
    @objc init(frame: CGRect, bounceDuration: CFTimeInterval, color: UIColor) {
        self.bounceDuration = bounceDuration
        self.waveLayer = CAShapeLayer() // CAShapeLayer(layer: self.layer)
        self.color = color
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        waveLayer.lineWidth = 0
        waveLayer.path = wavePath(amountX: 0.0, amountY: 0.0)
        waveLayer.strokeColor = color.cgColor
        waveLayer.fillColor = color.cgColor
        layer.addSublayer(waveLayer)
    }
    
    @objc func setWaveHeight(_ height: CGFloat) {
        waveLayer.path = wavePath(amountX: 0, amountY: height)
    }
    
    @objc func didRelease(amountX: CGFloat, amountY: CGFloat) {
        boundAnimation(positionX: amountX, positionY: amountY)
        didEndPull()
    }
    
    @objc func boundAnimation(positionX: CGFloat, positionY: CGFloat) {
        waveLayer.path = wavePath(amountX: 0, amountY: 0)
        let bounce = CAKeyframeAnimation(keyPath: "path")
        bounce.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        let values = [
            wavePath(amountX: positionX,            amountY: positionY),
            wavePath(amountX: -(positionX * 0.7),   amountY: -(positionY * 0.7)),
            wavePath(amountX: positionX * 0.4,      amountY: positionY * 0.4),
            wavePath(amountX: -(positionX * 0.3),   amountY: -(positionY * 0.3)),
            wavePath(amountX: positionX * 0.15,     amountY: positionY * 0.15),
            wavePath(amountX: 0.0,                  amountY: 0.0)
        ]
        bounce.values = values
        bounce.duration = bounceDuration
        bounce.isRemovedOnCompletion = true
        bounce.fillMode = CAMediaTimingFillMode.forwards
        bounce.delegate = self
        waveLayer.add(bounce, forKey: "return")
    }
    
    @objc func wavePath(amountX: CGFloat, amountY: CGFloat) -> CGPath {
        let w = frame.width
        let h = frame.height
        let centerY: CGFloat = 0
        let bottomY = h
        
        let topLeftPoint = CGPoint(x: 0, y: centerY)
        let topMidPoint = CGPoint(x: w / 2 + amountX, y: centerY + amountY)
        let topRightPoint = CGPoint(x: w, y: centerY)
        let bottomLeftPoint = CGPoint(x: 0, y: bottomY)
        let bottomRightPoint = CGPoint(x: w, y: bottomY)
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: bottomLeftPoint)
        bezierPath.addLine(to: topLeftPoint)
        bezierPath.addQuadCurve(to: topRightPoint, controlPoint: topMidPoint)
        bezierPath.addLine(to: bottomRightPoint)
        
        return bezierPath.cgPath
    }
}

extension WaveView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        waveLayer.path = wavePath(amountX: 0.0, amountY: 0.0)
    }
}
