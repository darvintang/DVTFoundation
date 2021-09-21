//
//  File.swift
//
//
//  Created by darvintang on 2021/9/21.
//

import Foundation

public protocol NameSpaceWrapper {
    associatedtype BaseType
    var base: BaseType { get }
    init(_ value: BaseType)
}

public struct NameSpaceBaseWrapper<BaseType>: NameSpaceWrapper {
    public private(set) var base: BaseType
    public init(_ value: BaseType) {
        self.base = value
    }
}

public protocol NameSpace {
    associatedtype BaseType
    var dvt: BaseType { get }
    static var dvt: BaseType.Type { get }
}

public extension NameSpace {
    var dvt: NameSpaceBaseWrapper<Self> {
        NameSpaceBaseWrapper(self)
    }

    static var dvt: NameSpaceBaseWrapper<Self>.Type {
        NameSpaceBaseWrapper.self
    }
}
