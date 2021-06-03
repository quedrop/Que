//
//  Ext+UIViewAnimation.swift
//  ChatDemo
//
//  Created by C100-105 on 08/04/19.
//  Copyright © 2019 C100-105. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    enum SlideDirection: Int {
        case RIGHT = 0
        case LEFT
        case TOP
        case BOTTOM
        case CENTER
        case XCENTER
        case YCENTER
    }
    
    enum Zoom: Int {
        case ZoomIn = 0
        case ZoomOut
    }
    
    enum Slide: Int {
        case SlideIn = 0
        case SlideOut
    }
    
    func animation(fadeInDuration duration: TimeInterval, delay: TimeInterval) {
        alpha = 0.3
        UIView.animate (
            withDuration: duration,
            delay: delay,
            animations: {
                self.alpha = 1
        })
    }
    
    func animation(downToUpDuration duration: TimeInterval, delay: TimeInterval) {
        transform = CGAffineTransform(translationX: 0, y: frame.height)
        
        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.1,
            options: [UIView.AnimationOptions.curveEaseInOut],
            animations: {
                self.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }
    
    func animation(downToUpSlowDuration duration: TimeInterval, delay: TimeInterval) {
        transform = CGAffineTransform(translationX: 0, y: frame.height / 3)
        
        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: 10,
            initialSpringVelocity: 2,
            options: [UIView.AnimationOptions.curveEaseInOut],
            animations: {
                self.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }
    
    func animation(zoomInOutTxtDuration duration: TimeInterval, delay: TimeInterval) {
        UIView.animate (
            withDuration: duration,
            delay: delay,
            animations: {
                self.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
        
        UIView.animate (
            withDuration: duration,
            delay: delay,
            animations: {
                self.layer.transform = CATransform3DMakeScale(1, 2, 2)
        })
        
        UIView.animate (
            withDuration: duration,
            delay: 0,
            animations: {
                self.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    
    func animation(zoomDuration duration: TimeInterval, delay: TimeInterval, zoom: Zoom) {
        let scale: CGFloat = zoom == .ZoomIn ? 0.5 : 1.1
        let finalPosition = CATransform3DMakeScale(scale, scale, scale)
        let origional = CATransform3DMakeScale(1, 1, 1)
        
        UIView.animate (
            withDuration: duration,
            delay: delay,
            animations: {
                self.layer.transform = finalPosition
        },
            completion: {
                finished in
                UIView.animate (
                    withDuration: duration,
                    delay: 0.1,
                    animations: {
                        self.layer.transform = origional
                })
        })
    }
    
    func animation(zoomInOutDuration duration: TimeInterval, delay: TimeInterval) {
        self.animation(zoomDuration: duration, delay: delay, zoom: .ZoomIn)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(duration) + Int(duration)), execute: {
            self.animation(zoomDuration: duration, delay: delay, zoom: .ZoomOut)
        })
    }
    
    func animation(zoomOutInDuration duration: TimeInterval, delay: TimeInterval) {
        self.animation(zoomDuration: duration, delay: delay, zoom: .ZoomOut)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(duration) + Int(duration)), execute: {
            self.animation(zoomDuration: duration, delay: delay, zoom: .ZoomIn)
        })
    }
    
    func animation(rotateDuration duration: TimeInterval, delay: TimeInterval) {
        let rotationAngleInRadians = 360.0 * CGFloat(.pi / 360.0)
        //  let rotationTransform = CATransform3DMakeRotation(rotationAngleInRadians, -500, 100, 0)
        let rotationTransform = CATransform3DMakeRotation(rotationAngleInRadians, 0, 0, 1)
        layer.transform = rotationTransform
        
        UIView.animate(
            withDuration: duration,
            delay: delay,
            animations: {
                self.layer.transform = CATransform3DIdentity
        })
    }
    
    func animation(slideDuration duration: TimeInterval, delay: TimeInterval, direction: SlideDirection, slide: Slide, withScreen: Bool = true) {
        let width = withScreen ? UIScreen.main.bounds.size.width : bounds.width
        let height = withScreen ? UIScreen.main.bounds.size.height : bounds.height
        
        let left = CGAffineTransform(translationX: -width, y: 0)
        let right = CGAffineTransform(translationX: width, y: 0)
        let top = CGAffineTransform(translationX: 0, y: -height)
        let bottom = CGAffineTransform(translationX: 0, y: height)
        
        let center = CGAffineTransform(translationX: width / 2, y: height / 2)
        let ycenter = CGAffineTransform(translationX: 0, y: height / 2)
        let xcenter = CGAffineTransform(translationX: width / 2, y: 0)
        let origional = CGAffineTransform(translationX: 0, y: 0)
        
        var start = origional
        
        switch direction {
        case .LEFT:
            start = left
            
        case .RIGHT:
            start = right
            
        case .TOP:
            start = top
            
        case .BOTTOM:
            start = bottom
            
        case .CENTER:
            start = center
            
        case .XCENTER:
            start = xcenter
            
        case .YCENTER:
            start = ycenter
        }
        
        transform = slide == .SlideIn ? start : origional
        
        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: .curveEaseInOut,
            animations: {
                self.transform = slide == .SlideIn ? origional : start
        },
            completion: nil)
    }
    
    func animation(shakeDelay delay: TimeInterval) {
        self.transform = CGAffineTransform(translationX: 20, y: 0)
        UIView.animate(
            withDuration: 0.8,
            delay: delay,
            usingSpringWithDamping: 0.1,
            initialSpringVelocity: 10,
            options: .curveEaseInOut,
            animations: {
                self.transform = CGAffineTransform.identity
        },
            completion: nil)
    }
    
}
