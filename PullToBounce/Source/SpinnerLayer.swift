//
//  SpinnerLayer.swift
//  PullToBounce
//
//  Created by Takuya Okamoto on 2015/08/11.
//  Copyright (c) 2015年 Uniface. All rights reserved.
//

import UIKit

class SpinerLayer :CAShapeLayer, CAAnimationDelegate {
    @objc init(superLayerFrame: CGRect,
               spinnerSize: CGFloat,
               color: UIColor = .white) {
        super.init()
        
        let radius:CGFloat = (spinnerSize / 2) * 1.2
        self.frame = CGRect(x: 0, y: 0, width: superLayerFrame.height, height: superLayerFrame.height)
        let center = CGPoint(x: superLayerFrame.size.width / 2, y: superLayerFrame.origin.y + superLayerFrame.size.height/2)
        let startAngle = 0 - Double.pi / 2
        let endAngle = (Double.pi * 2 - (Double.pi / 2)) + Double.pi / 8
        let clockwise: Bool = true
        
        path = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: clockwise).cgPath
        fillColor = nil
        strokeColor = color.withAlphaComponent(1).cgColor
        lineWidth = 2
        lineCap = CAShapeLayerLineCap.round
        strokeStart = 0
        strokeEnd = 0
        isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func animation() {
        self.isHidden = false
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.fromValue = 0
        rotate.toValue = Double.pi * 2
        rotate.duration = 1
        rotate.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        rotate.repeatCount = HUGE
        rotate.fillMode = CAMediaTimingFillMode.forwards
        rotate.isRemovedOnCompletion = false
        add(rotate, forKey: rotate.keyPath)
        
        strokeEndAnimation()
    }
    
    @objc func strokeEndAnimation() {
        let endPoint = CABasicAnimation(keyPath: "strokeEnd")
        endPoint.fromValue = 0
        endPoint.toValue = 1.0
        endPoint.duration = 0.8
        endPoint.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        endPoint.repeatCount = 1
        endPoint.fillMode = CAMediaTimingFillMode.forwards
        endPoint.isRemovedOnCompletion = false
        endPoint.delegate = self
        add(endPoint, forKey: endPoint.keyPath)
    }
    
    @objc func strokeStartAnimation() {
        let startPoint = CABasicAnimation(keyPath: "strokeStart")
        startPoint.fromValue = 0
        startPoint.toValue = 1.0
        startPoint.duration = 0.8
        startPoint.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        startPoint.repeatCount = 1
        startPoint.delegate = self
        add(startPoint, forKey: startPoint.keyPath)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if isHidden == false {
            let a: CABasicAnimation = anim as! CABasicAnimation
            if a.keyPath == "strokeStart" {
                strokeEndAnimation()
            }
            else if a.keyPath == "strokeEnd" {
                strokeStartAnimation()
            }
        }
    }
    
    @objc func stopAnimation() {
        isHidden = true
        removeAllAnimations()
    }
}
