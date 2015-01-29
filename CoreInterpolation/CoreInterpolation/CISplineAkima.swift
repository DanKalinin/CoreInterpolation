//
//  CISplineAkima.swift
//  CoreInterpolation
//
//  Created by Dan Kalinin on 12.01.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

import UIKit
import Accelerate



class CISplineAkima: CISpline {
    
    //MARK: Variables
    
    var dss: [CGFloat]!
    
    //MARK: Callback methods
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        return CISplineAkima(ps: ps)
    }
    
    //MARK: Methods
    
    override func calcMs() {
        super.calcMs()
        
        if n == 2 {
            ms[0].a = ps[0].y
            ms[0].b = (ps[1].y - ps[0].y) / (ps[1].x - ps[0].x)
            return
        }
        
        calcDss()
        var i1, i2: Int
        var dx1: Float
        var a, xb: [Float]
        for i in 0...n - 2 {
            i1 = i; i2 = i + 1
            dx1 = ps[i2].x.f - ps[i1].x.f
            
            a = [
                pow(dx1, 2), pow(dx1, 3),
                0, pow(dx1, 2)
            ]
            xb = [
                ps[i2].y.f - ps[i1].y.f - dss[i1].f * dx1,
                2 * (ps[i1].y.f - ps[i2].y.f) / dx1 + dss[i2].f + dss[i1].f
            ]
            cblas_strsv(CblasRowMajor, CblasUpper, CblasNoTrans, CblasNonUnit, 2, a, 2, &xb, 1)
            
            ms[i].a = ps[i].y
            ms[i].b = dss[i]
            ms[i].c.f = xb[0]
            ms[i].d.f = xb[1]
        }
    }
    
    func calcDss() {
        if dss == nil || dss.count < n {
            dss = [CGFloat](count: n, repeatedValue: 0)
        }
        
        var i1, i2, i3, i4, i5: Int!
        var m1, m2, m3, m4: CGFloat!
        var w1, w2: CGFloat
        
        func msLeft() {
            m2 = i2 < 0 ? 2 * m3 - m4 : (ps[i3].y - ps[i2].y) / (ps[i3].x - ps[i2].x)
            m1 = i1 < 0 ? 2 * m2 - m3 : (ps[i2].y - ps[i1].y) / (ps[i2].x - ps[i1].x)
        }
        
        func msRight() {
            m3 = i4 > n - 1 ? 2 * m2 - m1 : (ps[i4].y - ps[i3].y) / (ps[i4].x - ps[i3].x)
            m4 = i5 > n - 1 ? 2 * m3 - m2 : (ps[i5].y - ps[i4].y) / (ps[i5].x - ps[i4].x)
        }
        
        for i in 0...n - 1 {
            i1 = i - 2; i2 = i - 1; i3 = i; i4 = i + 1; i5 = i + 2
            if i1 < 0 {     //ms - L
                msRight()
                msLeft()
            } else {        //ms - R, Middle
                msLeft()
                msRight()
            }
            
            if m2 == m3 {   //dss
                dss[i] = m2
            } else if m1 == m2 && m3 != m4 {
                dss[i] = m1
            } else if m1 != m2 && m3 == m4 {
                dss[i] = m3
            } else if m1 == m2 && m3 == m4 && m2 != m3 {
                dss[i] = (m2 + m3) / 2
            } else {
                w1 = abs(m4 - m3)
                w2 = abs(m2 - m1)
                dss[i] = (w1 * m2 + w2 * m3) / (w1 + w2)
            }
        }
    }
}