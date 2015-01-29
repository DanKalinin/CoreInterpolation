//
//  Helpers.swift
//  CoreInterpolation
//
//  Created by Dan Kalinin on 12.01.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

import UIKit



//MARK: Swift

extension Int {
    var f: Float {
        get {return Float(self)}
        set {self = Int(newValue)}
    }
}

extension UInt {
    var i: Int {
        get {return Int(self)}
        set {self = UInt(newValue)}
    }
}

//

struct Stack<T> {
    
    typealias Element = T
    
    var elements = [Element]()
    var emptyElement: Element
    
    var isEmpty: Bool {
        return elements.isEmpty
    }
    
    init(emptyElement: Element) {
        self.emptyElement = emptyElement
    }
    
    mutating func push(e: Element) {
        elements.append(e)
    }
    
    mutating func pop() -> Element {
        return elements.isEmpty ? emptyElement : elements.removeLast()
    }
}

//MARK: CG

extension CGFloat {
    var f: Float {
        get {return Float(self)}
        set {self = CGFloat(newValue)}
    }
}

//

let CGVectorZero = CGVectorMake(0, 0)

//MARK: UI

let kUIScreenScale = UIScreen.mainScreen().scale