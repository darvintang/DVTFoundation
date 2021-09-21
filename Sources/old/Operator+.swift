//
//  XTIOperator+.swift
//  XTIBaseTool
//
//  Created by xtinput on 2020/12/24.
//

import Foundation

public extension Double {
    static func += (left: inout Double, right: Int) {
        left = left + Double(right)
    }

    static func += (left: inout Double, right: Int8) {
        left = left + Double(right)
    }

    static func += (left: inout Double, right: Int32) {
        left = left + Double(right)
    }

    static func += (left: inout Double, right: Int64) {
        left = left + Double(right)
    }

    static func -= (left: inout Double, right: Int) {
        left = left - Double(right)
    }

    static func -= (left: inout Double, right: Int8) {
        left = left - Double(right)
    }

    static func -= (left: inout Double, right: Int32) {
        left = left - Double(right)
    }

    static func -= (left: inout Double, right: Int64) {
        left = left - Double(right)
    }

    static postfix func ++ (left: inout Double) {
        left = left + 1
    }

    static postfix func -- (left: inout Double) {
        left = left - 1
    }
}

public extension Int {
    static postfix func ++ (left: inout Int) {
        left = left + 1
    }

    static postfix func -- (left: inout Int) {
        left = left - 1
    }
}
