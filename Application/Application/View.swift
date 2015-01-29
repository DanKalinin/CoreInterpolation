//
//  View.swift
//  Application
//
//  Created by Dan Kalinin on 12.01.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

import UIKit
import CoreInterpolation



class View: UIView {
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let ctx = UIGraphicsGetCurrentContext()
        
        var points = [
            CGPointMake(50, 300),
            CGPointMake(100, 300),
            CGPointMake(150, 300),
            CGPointMake(200, 200),
            CGPointMake(250, 300),
            CGPointMake(300, 300),
            CGPointMake(350, 300)
        ]
        
        CGContextSetSplineType(ctx, kCGSplineCubic)
        CGContextAddCurves(ctx, points, UInt(points.count))
        
        
        
        
        
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        CGContextSetLineWidth(ctx, 3)
        CGContextDrawPath(ctx, kCGPathStroke)

        for point in points {
            CGContextMoveToPoint(ctx, point.x, point.y)
            CGContextAddArc(ctx, point.x, point.y, 7, 0, 2 * CGFloat(M_PI), 0)
        }
        CGContextSetFillColorWithColor(ctx, UIColor.redColor().CGColor)
        CGContextDrawPath(ctx, kCGPathFill)
    }
}