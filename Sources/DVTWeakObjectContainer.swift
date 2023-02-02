//
//  DVTWeakObjectContainer.swift
//
//
//  Created by darvin on 2023/1/10.
//

import Foundation

/// 弱引用包裹桥梁
public class DVTWeakObjectContainer<ObjectType: AnyObject>: NSObject {
    private var useObject: AnyObject? {
        self.object
    }

    public weak var object: ObjectType?

    public convenience init(object: ObjectType?) {
        self.init()
        self.object = object
    }

    override init() {
        super.init()
    }

    override public var description: String {
        "DVTWeakObjectContainer<\(self.useObject?.description ?? "nil")>"
    }

    override public var debugDescription: String {
        "DVTWeakObjectContainer<\(self.useObject?.debugDescription ?? "nil")>"
    }

    override public func isEqual(_ object: Any?) -> Bool {
        self.useObject?.isEqual(object) ?? false
    }

    override public var hash: Int {
        self.useObject?.hash ?? self.hash
    }

    override public var superclass: AnyClass? {
        self.useObject?.superclass
    }

    override public func isKind(of aClass: AnyClass) -> Bool {
        self.useObject?.isKind(of: aClass) ?? false
    }

    override public func isMember(of aClass: AnyClass) -> Bool {
        self.useObject?.isMember(of: aClass) ?? false
    }

    override public func conforms(to aProtocol: Protocol) -> Bool {
        self.useObject?.conforms(to: aProtocol) ?? super.conforms(to: aProtocol)
    }
}
