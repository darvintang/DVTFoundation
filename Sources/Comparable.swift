//
//  Comparable.swift
//
//
//  Created by darvin on 2023/4/25.
//

import Foundation

public enum ComparingResult: Int, Comparable {
    case less = -1
    case equal = 0
    case greater = 1

    // MARK: Public
    public static func < (lhs: ComparingResult, rhs: ComparingResult) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public extension Comparable {
    static var dvt: BaseWrapper<Self>.Type { BaseWrapper.self }

    var dvt: BaseWrapper<Self> { set { } get { BaseWrapper(self) }}
}

public extension BaseWrapper where BaseType: Comparable {
    func compare(_ target: BaseType) -> ComparingResult {
        if self.base == target {
            return .equal
        } else if self.base < target {
            return .less
        } else {
            return .greater
        }
    }
}
