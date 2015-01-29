//
//  CGExtension.swift
//  CoreInterpolation
//
//  Created by Dan Kalinin on 12.01.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

import UIKit



public func _CGContextSaveGState(c: CGContext!) {
    CGContextSaveGState(c)
    gStates.save(c)
}

public func _CGContextRestoreGState(c: CGContext!) {
    CGContextRestoreGState(c)
    gStates.restore(c)
}

public func CGContextSetSplineType(c: CGContext!, type: CGSplineType) {
    gStates.setCurrent(c, gState: CIGState(splineType: type))
}

public func CGContextAddCurves(c: CGContext!, points: UnsafePointer<CGPoint>, count: UInt) {
    //Points count control
    if count < 2 {
        return
    }
    //X sequence control
    var ps = [CGPoint]()
    var i1, i2: Int
    for i in 0..<count.i {
        ps.append(points.advancedBy(i).memory)
        i1 = i - 1; i2 = i
        if i1 >= 0 && ps[i1].x > ps[i2].x {
            return
        }
    }
    //Instanciate a type of the spline
    var spline = gStates.getCurrent(c).splineType.value
    if spline.ps == [CGPointZero] {
        spline = spline.copy() as CISpline
        gStates.setCurrent(c, gState: CIGState(splineType: CGSplineType(spline)))
    }
    //Calculate multipliers if points changed
    if spline.ps != ps {
        spline.ps = ps
        spline.calcMs()
    }
    //Add Beziers to the context
    for i in 0..<count.i - 1 {
        CGContextAddPath(c, spline.b(i))
    }
    
    //println(CFCopyTypeIDDescription(CFGetTypeID(c)))
    //println(CFGetTypeID(c))
    //println(CGContextGetTypeID())
    
    //let f: (CGContext!) -> Void = CGContextSaveGState
    
    //let a: AnyObject = c
    //println(reflect(a))
    
    //println(NSStringFromClass(CGContext.self))        //error - bad access
}

struct CIGStates {
    
    var gStates = [CFHashCode: Stack<CIGState>]()
    var gState = [CFHashCode: CIGState]()
    
    func getDefault() -> CIGState {
        return CIGState(splineType: kCGSplineCubic)
    }
    
    mutating func getCurrent(c: CGContext!) -> CIGState {
        return gState[CFHash(c)] ?? getDefault()
    }
    
    mutating func setCurrent(c: CGContext!, gState: CIGState) {
        self.gState[CFHash(c)] = gState
    }
    
    mutating func save(c: CGContext!) {
        let ch = CFHash(c)
        if gStates[ch] == nil {
            gStates[ch] = Stack(emptyElement: getDefault())
        }
        gStates[ch]!.push(getCurrent(c))
    }
    
    mutating func restore(c: CGContext!) {
        let ch = CFHash(c)
        if !(gStates[ch] == nil || gStates[ch]!.isEmpty) {
            setCurrent(c, gState: gStates[ch]!.pop())
        }
    }
}

struct CIGState {
    var splineType: CGSplineType
}

public struct CGSplineType {
    var value: CISpline
    init(_ value: CISpline) {
        self.value = value
    }
}

public let kCGSplineCubic = CGSplineType(CISplineCubic(ps: [CGPointZero]))
public let kCGSplineAkima = CGSplineType(CISplineAkima(ps: [CGPointZero]))

var gStates = CIGStates()