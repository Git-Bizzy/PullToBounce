//
//  BallView.swift
//  PullToBounce
//
//  Created by Takuya Okamoto on 2015/08/11.
//  Copyright (c) 2015年 Uniface. All rights reserved.
//

import UIKit

class BallView: UIView {
    @objc private var circle: UIView
    @objc private var circleLayer: CircleLayer
    @objc private var circleSize: CGFloat
    @objc private var timingFunc : CAMediaTimingFunction
    @objc private var moveUpDuration: CFTimeInterval
    
    @objc init(frame: CGRect,
               circleSize: CGFloat = 40,
               timingFunc: CAMediaTimingFunction,
               moveUpDuration: CFTimeInterval,
               moveUpDist: CGFloat,
               ballColor: UIColor = .white,
               spinnerColor: UIColor = .white) {
        self.timingFunc = timingFunc
        self.moveUpDuration = moveUpDuration
        self.circleSize = circleSize
        self.circle = UIView(frame: CGRect(x: 0, y: 0, width: moveUpDist, height: moveUpDist))
        self.circleLayer = CircleLayer(
            circleSize: circleSize,
            timingFunc: timingFunc,
            moveUpDuration: moveUpDuration,
            moveUpDist: moveUpDist,
            superViewFrame: circle.frame,
            ballColor: ballColor,
            spinnerColor: spinnerColor)
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        circle.center = CGPoint(x: frame.width/2, y: frame.height + circleSize / 2)
        addSubview(circle)
        circle.layer.addSublayer(circleLayer)
    }
    
    @objc func startAnimation() {
        circleLayer.startAnimation()
    }
    
    @objc func endAnimation(_ completion: @escaping () -> Void = {}) {
        circleLayer.endAnimation(completion)
    }
}
