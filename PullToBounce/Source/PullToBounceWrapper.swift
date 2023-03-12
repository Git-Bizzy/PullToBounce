//
//  PullToBounceWrapper.swift
//  PullToBounce
//
//  Created by Takuya Okamoto on 2015/08/12.
//  Copyright (c) 2015年 Uniface. All rights reserved.
//

// Inspired by https://dribbble.com/shots/1797373-Pull-Down-To-Refresh

import UIKit

/// Wrapper class for UIScrollViews. Adds pull to refresh functionality
open class PullToBounceWrapper: UIView {
    @objc open var scroll: UIScrollView
    @objc open var onRefresh: () -> Void = {}
    @objc private let bounceView: BounceView
    @objc private let pullDist: CGFloat
    @objc private let bendDist: CGFloat
    @objc private var fadesScrollOnScroll: Bool
    @objc private var isReloading: Bool = false
    @objc private var stopPos: CGFloat {
        get { pullDist + bendDist }
    }

    /// default inititializer.
    /// The only required parameter is scrollView.
    /// And you can customize animation by other parameters.
    @objc public init(
        scrollView: UIScrollView,
        bounceDuration: CFTimeInterval = 0.8,
        ballSize:CGFloat = 36,
        ballMoveTimingFunc: CAMediaTimingFunction = CAMediaTimingFunction(controlPoints:0.49,0.13,0.29,1.61),
        moveUpDuration: CFTimeInterval = 0.25,
        pullDistance: CGFloat = 96,
        bendDistance: CGFloat = 40,
        fadesScrollOnScroll: Bool = false,
        ballColor: UIColor = .white,
        spinnerColor: UIColor = .white,
        onRefresh: @escaping () -> Void = {}
    ) {
        if scrollView.frame == CGRect.zero {
            assert(false, "Wow, scrollView.frame is CGRectZero. Please set frame size.")
        }

        self.fadesScrollOnScroll = fadesScrollOnScroll
        self.pullDist = pullDistance
        self.bendDist = bendDistance
        self.onRefresh = onRefresh
        self.scroll = scrollView
        self.bounceView = BounceView(
            frame: scrollView.frame,
            bounceDuration: bounceDuration,
            ballSize: ballSize,
            ballMoveTimingFunc: ballMoveTimingFunc,
            moveUpDuration: moveUpDuration,
            moveUpDist: pullDistance/2 + ballSize/2,
            color: scrollView.backgroundColor,
            ballColor: ballColor,
            spinnerColor: spinnerColor)
        super.init(frame: scrollView.frame)
        
        setup()
        layout()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        scroll.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &KVOContext)
    }
    
    private func setup() {
        scroll.backgroundColor = UIColor.clear
        scroll.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .new, context: &KVOContext)
    }
    
    private func layout() {
        addSubview(bounceView)
        addSubview(scroll)
    }
    
    @objc private func didScroll() {
        if scroll.contentOffset.y < 0 {
            let y = scroll.contentOffset.y * -1
            if y < pullDist && !isReloading {
                bounceView.frame.y = y
                bounceView.setWaveHeight(0)
                if fadesScrollOnScroll { scroll.alpha = (pullDist - y)/pullDist }
            } else if y < stopPos && !isReloading {
                bounceView.setWaveHeight(y - pullDist)
                if fadesScrollOnScroll { scroll.alpha = 0 }
            } else if y > stopPos && !isReloading {
                self.isReloading = true
                if fadesScrollOnScroll { scroll.isScrollEnabled = false }
                scroll.contentInset.top = stopPos
                scroll.setContentOffset(CGPoint(x: scroll.contentOffset.x, y: -stopPos), animated: false)
                bounceView.frame.y = pullDist
                bounceView.setWaveHeight(stopPos - pullDist)
                bounceView.didRelease(stopPos - pullDist)
                onRefresh()
                if fadesScrollOnScroll { scroll.alpha = 0 }
            }
        } else {
            bounceView.frame.y = 0
            if fadesScrollOnScroll { scroll.alpha = 1 }
        }
    }
    
    @objc open func stopLoadingAnimation() {
        self.bounceView.endingAnimation {
            let animations = { self.scroll.contentInset.top = 0 }
            UIView.animate(withDuration: 0.25, delay: 0, animations: animations)
            self.scroll.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            self.scroll.isScrollEnabled = true
            self.isReloading = false
        }
    }
    
    // MARK: ScrollView KVO
    fileprivate var KVOContext = "PullToRefreshKVOContext"
    fileprivate let contentOffsetKeyPath = "contentOffset"
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (context == &KVOContext && keyPath == contentOffsetKeyPath && object as? UIScrollView == scroll) {
            DispatchQueue.main.async { self.didScroll() }
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
