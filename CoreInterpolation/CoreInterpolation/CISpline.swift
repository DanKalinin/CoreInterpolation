//
//  CISpline.swift
//  CoreInterpolation
//
//  Created by Dan Kalinin on 12.01.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

import UIKit
import Accelerate



class CISpline: NSObject, NSCopying, CISplinable {
    
    //MARK: Variables
    
    var ps: [CGPoint]
    var n: Int {
        get {return ps.count}
    }
    var ms: [ABCDMultiplier]
    
    //MARK: Initializer
    
    required init(ps: [CGPoint]) {
        self.ps = ps
        self.ms = [ABCDMultiplier](count: ps.count - 1, repeatedValue: ABCDMultiplierZero)
    }
    
    //MARK: Callback methods
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return CISpline(ps: ps)
    }
    
    //MARK: Methods
    
    func calcMs() {
        if ms.count < n - 1 {
            ms = [ABCDMultiplier](count: n - 1, repeatedValue: ABCDMultiplierZero)
        }
    }
    
    func s(i: Int, x: CGFloat) -> CGFloat {
        let dx = x - ps[i].x
        return ms[i].a + ms[i].b * dx + ms[i].c * pow(dx, 2) + ms[i].d * pow(dx, 3)
    }
    
    func b(i: Int) -> CGPath {
        
        let dx = ps[i + 1].x - ps[i].x
        
        let p0 = ps[i]
        var p1 = CGPointMake(p0.x + dx / 3, 0)
        var p2 = CGPointMake(p0.x + 2 * dx / 3, 0)
        let p3 = ps[i + 1]
        
        let s1 = s(i, x: p1.x)
        let s2 = s(i, x: p2.x)
        
        let a = [
            4.f/9, 2.f/9,
            0, 1.f/3
        ]
        var yb = [
            s1.f - p0.y.f * 8.f/27 - p3.y.f * 1.f/27,
            s2.f - s1.f * 1.f/2 + p0.y.f * 1.f/9 - p3.y.f * 15.f/54
        ]
        cblas_strsv(CblasRowMajor, CblasUpper, CblasNoTrans, CblasNonUnit, 2, a, 2, &yb, 1)
        p1.y.f = yb[0]
        p2.y.f = yb[1]
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, p0.x, p0.y)
        CGPathAddCurveToPoint(path, nil, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y)
        
        return path
    }
}



protocol CISplinable {
    //MARK: Variables
    var ps: [CGPoint] {get set}
    var n: Int {get}
    var ms: [ABCDMultiplier] {get set}
    //MARK: Initializer
    init(ps: [CGPoint])
    //MARK: Methods
    func calcMs()
    func s(i: Int, x: CGFloat) -> CGFloat
    func b(i: Int) -> CGPath
}



struct ABCDMultiplier {
    var a, b, c, d: CGFloat
}

struct ABMultiplier {
    var alpha, beta: CGFloat
}

let ABCDMultiplierZero = ABCDMultiplier(a: 0, b: 0, c: 0, d: 0)
let ABMultiplierZero = ABMultiplier(alpha: 0, beta: 0)