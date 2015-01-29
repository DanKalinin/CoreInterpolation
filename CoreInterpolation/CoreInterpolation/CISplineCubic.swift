//
//  CISplineCubic.swift
//  CoreInterpolation
//
//  Created by Dan Kalinin on 12.01.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

import UIKit
import Accelerate



class CISplineCubic: CISpline {
    
    //MARK: Variables
    
    //Shuttle method variables
    
    var cms: [ABCDMultiplier]!  //a, b, c, d
    var sms: [ABMultiplier]!    //alpha, beta
    var xs: [CGFloat]!          //xs
    
    //MARK: Callback methods
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        return CISplineCubic(ps: ps)
    }
    
    //MARK: Methods
    
    override func calcMs() {
        super.calcMs()
        if cms == nil || cms.count < n - 2 {
            cms = [ABCDMultiplier](count: n - 2, repeatedValue: ABCDMultiplierZero)
        }
        var i1, i2, i3: Int
        var drs = [CGVector](count: n - 1, repeatedValue: CGVectorZero)
        drs[0] = CGVectorMake(ps[1].x - ps[0].x, ps[1].y - ps[0].y)
        for var i = 0; i <= n - 3; i++ {
            i1 = i; i2 = i + 1; i3 = i + 2
            drs[i2] = CGVectorMake(ps[i3].x - ps[i2].x, ps[i3].y - ps[i2].y)
            cms[i].a = drs[i1].dx
            cms[i].b = 2 * (drs[i2].dx + drs[i1].dx)
            cms[i].c = drs[i2].dx
            cms[i].d = 6 * (drs[i2].dy / drs[i2].dx - drs[i1].dy / drs[i1].dx)
        }
        //c(0) = 0, c(n-1) = 0
        var cs = [0] + shuttle(cms) + [0]
        for i in 0...n - 2 {
            i1 = i; i2 = i + 1
            ms[i].a = ps[i].y
            ms[i].b = drs[i].dy / drs[i].dx - (2 * cs[i1] + cs[i2]) * drs[i].dx / 6
            ms[i].c = cs[i] / 2
            ms[i].d = (cs[i2] - cs[i1]) / (6 * drs[i].dx)
        }
    }
    
    func shuttle(ms: [ABCDMultiplier]) -> [CGFloat] {
        if sms == nil || sms.count < ms.count {
            sms = [ABMultiplier](count: ms.count + 1, repeatedValue: ABMultiplierZero)
            xs = [CGFloat](count: ms.count, repeatedValue: 0)
        }
        if !ms.isEmpty {
            var i1, i2: Int
            for i in 0...ms.count - 1 {
                i1 = i; i2 = i + 1
                sms[i2].alpha = -ms[i1].c / (ms[i1].a * sms[i1].alpha + ms[i1].b)
                sms[i2].beta = (ms[i1].d - ms[i1].a * sms[i1].beta) / (ms[i1].b + ms[i1].a * sms[i1].alpha)
            }
            xs[ms.count - 1] = sms[ms.count].beta
            for var i = ms.count - 2; i >= 0; i-- {
                i1 = i; i2 = i + 1
                xs[i1] = sms[i2].alpha * xs[i2] + sms[i2].beta
            }
        }
        return xs
    }
}