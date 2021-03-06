//
//  File.swift
//
//
//  Created by darvin on 2021/10/22.
//
/*

 MIT License

 Copyright (c) 2021 darvin http://blog.tcoding.cn

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

public struct JSONBaseWrapper<JT> {
    public var base: JT
    public init(_ value: JT) {
        self.base = value
    }
}

public protocol JSONNameSpace {
    associatedtype JT
    var dvtJson: JT { set get }
    static var dvtJson: JT.Type { get }
}

public extension JSONNameSpace {
    var dvtJson: JSONBaseWrapper<Self> { set {} get { JSONBaseWrapper(self) }}
    static var dvtJson: JSONBaseWrapper<Self>.Type { JSONBaseWrapper.self }
}

extension JSONBaseWrapper where JT: MirrorProtocol {
    public var json: Any? {
        self.base.mirrorValue
    }

    public var jsonString: String? {
        if let value = self.json, let data = try? JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

public protocol MirrorProtocol {
    var mirrorValue: Any? { get }
}

extension MirrorProtocol {
    public var mirrorValue: Any? {
        var dict: [String: Any] = [:]
        Mirror(reflecting: self).children.forEach { child in
            if let key = child.label {
                if let value = child.value as? MirrorProtocol {
                    dict[key] = value.mirrorValue
                } else {
                    dict[key] = child.value
                }
            }
        }
        return dict
    }
}

extension Array: MirrorProtocol {
    public var mirrorValue: Any? {
        self.compactMap { e -> Any? in
            if let v = e as? MirrorProtocol {
                return v.mirrorValue
            } else {
                return e
            }
        }
    }
}

extension Dictionary: MirrorProtocol {
    public var mirrorValue: Any? {
        var dict: [String: Any] = [:]
        self.forEach { (key: Hashable, value: Value) in
            dict["\(key)"] = value
            if let v = value as? MirrorProtocol {
                dict["\(key)"] = v.mirrorValue
            }
        }
        return dict
    }
}

extension Set: MirrorProtocol {
    public var mirrorValue: Any? {
        self.compactMap { e -> Any? in
            if let v = e as? MirrorProtocol {
                return v.mirrorValue
            } else {
                return e
            }
        }
    }
}

extension NSObject: MirrorProtocol {
    public var mirrorValue: Any? {
        if let list = self as? [Any] {
            return list.mirrorValue
        }
        if let dict = self as? [String: Any] {
            return dict.mirrorValue
        }
        if let set = self as? NSSet {
            return set.compactMap { e -> Any? in
                if let v = e as? MirrorProtocol {
                    return v.mirrorValue
                } else {
                    return e
                }
            }
        }
        var dict: [String: Any] = [:]
        Mirror(reflecting: self).children.forEach { child in
            if let key = child.label {
                if let value = child.value as? MirrorProtocol {
                    dict[key] = value.mirrorValue
                } else {
                    dict[key] = child.value
                }
            }
        }
        return dict
    }
}

// extension String: MirrorProtocol {
//    public var mirrorValue: Any? {
//        return self.data(using: .utf8)?.mirrorValue ?? self
//    }
// }
//
// extension Data: MirrorProtocol {
//    public var mirrorValue: Any? {
//        return try? JSONSerialization.jsonObject(with: self, options: .fragmentsAllowed)
//    }
// }

extension NSObject: JSONNameSpace { }
extension Array: JSONNameSpace {}
extension Dictionary: JSONNameSpace {}
extension Set: JSONNameSpace {}
extension String: JSONNameSpace {}
// extension Data: JSONNameSpace {}

extension JSONBaseWrapper where JT == String {
    public var json: Any? {
        if let data = self.base.data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
        }
        return nil
    }
}
