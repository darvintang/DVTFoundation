//
//  DVTWeakObjectContainer.swift
//  DVTFoundation
//
//  Created by darvin on 2023/1/10.
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

/// 弱引用包裹桥梁
public class DVTWeakObjectContainer<ObjectType: AnyObject>: NSObject {
    // MARK: Lifecycle
    public convenience init(object: ObjectType?) {
        self.init()
        self.object = object
    }

    override init() { super.init() }

    // MARK: Public
    public weak var object: ObjectType?

    override public var description: String { "DVTWeakObjectContainer<\(self.useObject?.description ?? "nil")>" }

    override public var debugDescription: String {
        "DVTWeakObjectContainer<\(self.useObject?.debugDescription ?? "nil")>"
    }

    override public var hash: Int { self.useObject?.hash ?? self.hash }

    override public var superclass: AnyClass? { self.useObject?.superclass }

    override public func isEqual(_ object: Any?) -> Bool { self.useObject?.isEqual(object) ?? false }

    override public func isKind(of aClass: AnyClass) -> Bool { self.useObject?.isKind(of: aClass) ?? false }

    override public func isMember(of aClass: AnyClass) -> Bool { self.useObject?.isMember(of: aClass) ?? false }

    override public func conforms(to aProtocol: Protocol) -> Bool { self.useObject?.conforms(to: aProtocol) ?? super
        .conforms(to: aProtocol)
    }

    // MARK: Private
    private var useObject: AnyObject? { self.object }
}
