//
//  CircleLayer.swift
//  PullToBounce
//
//  Created by Takuya Okamoto on 2015/08/11.
//  Copyright (c) 2015年 Uniface. All rights reserved.
//

import UIKit

class CircleLayer: CAShapeLayer {
    @objc private let timingFunc: CAMediaTimingFunction
    @objc private let moveUpDuration: CFTimeInterval
    @objc private let moveUpDist: CGFloat
    @objc private let circleSize: CGFloat
    @objc private let circleColor: UIColor
    @objc private let spiner: SpinerLayer
    @objc var didEndAnimation: () -> Void =  {}
    
    @objc init(circleSize: CGFloat,
               timingFunc: CAMediaTimingFunction,
               moveUpDuration: CFTimeInterval,
               moveUpDist: CGFloat,
               superViewFrame: CGRect,
               ballColor: UIColor = .white,
               spinnerColor: UIColor = .white) {
        self.timingFunc = timingFunc
        self.moveUpDuration = moveUpDuration
        self.moveUpDist = moveUpDist
        self.circleSize = circleSize
        self.circleColor = ballColor
        self.spiner = SpinerLayer(superLayerFrame: .init(origin: .zero, size: superViewFrame.size), spinnerSize: circleSize, color: spinnerColor)
        super.init()
        self.frame = superViewFrame
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSublayer(spiner)
        let radius: CGFloat = circleSize / 2
        let center = CGPoint(x: frame.size.width / 2, y: frame.size.height/2)
        let startAngle = 0 - Double.pi / 2
        let endAngle = Double.pi * (Double.pi / 2)
        let clockwise: Bool = true
        path = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: clockwise).cgPath
        fillColor = circleColor.withAlphaComponent(1).cgColor
        strokeColor = fillColor
        lineWidth = 0
        strokeEnd = 1
    }
    
    @objc func startAnimation() {
        moveUp(moveUpDist)
        _ = Timer.schedule(delay: moveUpDuration) { timer in
            self.spiner.animation()
        }
    }
    
    @objc func endAnimation(_ completion: @escaping () -> Void = {}) {
        spiner.stopAnimation()
        moveDown(moveUpDist)
        didEndAnimation = completion
    }
    
    @objc private func moveUp(_ distance: CGFloat) {
        let move = CABasicAnimation(keyPath: "position")
        move.fromValue = NSValue(cgPoint: position)
        move.toValue = NSValue(cgPoint: CGPoint(x: position.x, y: position.y - distance))
        move.duration = moveUpDuration
        move.timingFunction = timingFunc
        move.fillMode = CAMediaTimingFillMode.forwards
        move.isRemovedOnCompletion = false
        add(move, forKey: move.keyPath)
    }
    
    @objc private func moveDown(_ distance: CGFloat) {
        let move = CABasicAnimation(keyPath: "position")
        move.fromValue = NSValue(cgPoint: CGPoint(x: position.x, y: position.y - distance))
        move.toValue = NSValue(cgPoint: position)
        move.duration = moveUpDuration
        move.timingFunction = timingFunc
        move.fillMode = CAMediaTimingFillMode.forwards
        move.isRemovedOnCompletion = false
        move.delegate = self
        add(move, forKey: move.keyPath)
    }
}

extension CircleLayer: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        didEndAnimation()
    }
}
