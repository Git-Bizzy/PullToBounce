//
//  BounceView.swift
//  PullToBounce
//
//  Created by Takuya Okamoto on 2015/08/11.
//  Copyright (c) 2015年 Uniface. All rights reserved.
//

import UIKit

class BounceView: UIView {
    @objc private let ballView: BallView
    @objc private let waveView: WaveView
    
    @objc init(
        frame: CGRect,
        bounceDuration: CFTimeInterval = 0.8,
        ballSize:CGFloat = 28,
        ballViewHeight: CGFloat = 100,
        ballMoveTimingFunc: CAMediaTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut),
        moveUpDuration: CFTimeInterval = 0.2,
        moveUpDist: CGFloat = 32 * 1.5,
        color: UIColor? = nil,
        ballColor: UIColor = .white,
        spinnerColor: UIColor = .white
    ) {
        let defaultColor = color ?? .white
        
        ballView = BallView(
            frame: CGRect(x: 0, y: -(ballViewHeight + 1), width: frame.width, height: ballViewHeight),
            circleSize: ballSize,
            timingFunc: ballMoveTimingFunc,
            moveUpDuration: moveUpDuration,
            moveUpDist: moveUpDist,
            ballColor: ballColor,
            spinnerColor: spinnerColor)
        
        waveView = WaveView(
            frame:CGRect(x: 0, y: 0, width: ballView.frame.width, height: frame.height),
            bounceDuration: bounceDuration,
            color: defaultColor
        )
        
        super.init(frame: frame)
        
        setup()
        layout()
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        ballView.isHidden = true
        waveView.didEndPull = {
            _ = Timer.schedule(delay: 0.2) { timer in
                self.ballView.isHidden = false
                self.ballView.startAnimation()
            }
        }
    }
    
    private func layout() {
        addSubview(ballView)
        addSubview(waveView)
    }
    
    @objc func endingAnimation(_ completion: @escaping () -> Void = {}) {
        ballView.endAnimation {
            self.ballView.isHidden = true
            completion()
        }
    }
    
    @objc func setWaveHeight(_ height: CGFloat) {
        waveView.setWaveHeight(height)
    }
    
    @objc func didRelease(_ y: CGFloat) {
        waveView.didRelease(amountX: 0, amountY: y)
    }
}
