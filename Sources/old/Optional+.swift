//
//  XTIOptional+.swift
//  XTIBaseTool
//
//  Created by xtinput on 2021/5/7.
//

import Foundation

public extension Optional where Wrapped: Comparable {
    static func < (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
        if lhs == rhs {
            return false
        }
        if lhs == nil {
            return true
        }
        if rhs == nil {
            return false
        }

        return lhs! < rhs!
    }

    static func > (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
        if lhs == rhs {
            return false
        }
        return !(lhs < rhs)
    }
}

public extension Optional where Wrapped == String {
    var isEmpty: Bool {
        return self == nil || (self ?? "").isEmpty
    }

    var cuont: Int {
        return (self ?? "").count
    }
}
