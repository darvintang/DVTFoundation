//
//  Operator.swift
//  DVTFoundation
//
//  Created by darvin on 2020/12/24.
//

/*

 MIT License

 Copyright (c) 2023 darvin http://blog.tcoding.cn

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.

 */

import Foundation

public extension Double {
    static func += <T: FixedWidthInteger>(left: inout Double, rhs: T) {
        if let r = Double(exactly: rhs) { left = left + r }
    }

    static func -= <T: FixedWidthInteger>(left: inout Double, rhs: T) {
        if let r = Double(exactly: rhs) { left = left - r }
    }

    static func += <T: BinaryFloatingPoint>(left: inout Double, rhs: T) {
        if T.self is Double.Type { left = left - (rhs as! Double) }
        else if let r = Double(exactly: rhs) { left = left + r }
    }

    static func -= <T: BinaryFloatingPoint>(left: inout Double, rhs: T) {
        if T.self is Double.Type { left = left - (rhs as! Double) }
        else if let r = Double(exactly: rhs) { left = left - r }
    }
}

public extension Float {
    static func += <T: FixedWidthInteger>(left: inout Float, rhs: T) {
        if let r = Float(exactly: rhs) { left = left + r }
    }

    static func -= <T: FixedWidthInteger>(left: inout Float, rhs: T) {
        if let r = Float(exactly: rhs) { left = left - r }
    }

    static func += <T: BinaryFloatingPoint>(left: inout Float, rhs: T) {
        if T.self is Float.Type { left = left + (rhs as! Float) }
        else if let r = Float(exactly: rhs) { left = left + r }
    }

    static func -= <T: BinaryFloatingPoint>(left: inout Float, rhs: T) {
        if T.self is Float.Type { left = left - (rhs as! Float) }
        else if let r = Float(exactly: rhs) { left = left - r }
    }
}

public extension Dictionary where Key == String, Value == Any {
    static func += (left: inout [String: Any], right: [String: Any]?) {
        right?.forEach { key, value in left[key] = value }
    }
}
