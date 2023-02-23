//
//  MirrorProtocol.swift
//  DVTFoundation
//
//  Created by darvin on 2021/10/22.
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

public protocol MirrorProtocol {
    var mirrorValue: Any? { get }
    var jsonString: String? { get }
}

public extension MirrorProtocol {
    var mirrorValue: Any? {
        var dict: [String: Any] = [:]
        Mirror(reflecting: self).children.forEach { child in
            if let key = child.label {
                if let value = child.value as? MirrorProtocol {
                    dict[key] = value.mirrorValue
                } else if JSONSerialization.isValidJSONObject(child.value) {
                    dict[key] = child.value
                }
            }
        }
        return dict
    }

    var jsonString: String? {
        if let value = self.mirrorValue, let data = try? JSONSerialization.data(withJSONObject: value, options: [.sortedKeys, .fragmentsAllowed]) {
            return String(data: data, encoding: .utf8)?.dvt.replacing("\\/", with: "/")
        }
        return nil
    }
}

extension Array: MirrorProtocol {
    public var mirrorValue: Any? {
        self.compactMap { e -> Any? in
            if let v = e as? MirrorProtocol { return v.mirrorValue }
            else if JSONSerialization.isValidJSONObject(e) { return e }
            else { return nil }
        }
    }
}

extension Dictionary: MirrorProtocol {
    public var mirrorValue: Any? {
        var dict: [String: Any] = [:]
        self.forEach { (key: Hashable, value: Value) in
            dict["\(key)"] = value
            if let v = value as? MirrorProtocol { dict["\(key)"] = v.mirrorValue }
            else if JSONSerialization.isValidJSONObject(value) { dict["\(key)"] = value }
        }
        return dict
    }
}

extension Set: MirrorProtocol {
    public var mirrorValue: Any? {
        self.compactMap { e -> Any? in
            if let v = e as? MirrorProtocol { return v.mirrorValue }
            else if JSONSerialization.isValidJSONObject(e) { return e }
            else { return nil }
        }
    }
}

extension NSObject: MirrorProtocol {
    // MARK: Public
    public var mirrorValue: Any? {
        if let list = self as? [Any] { return list.mirrorValue }

        if let dict = self as? [String: Any] { return dict.mirrorValue }

        if let set = self as? NSSet {
            return set.compactMap { e -> Any? in
                if let v = e as? MirrorProtocol { return v.mirrorValue }
                else if JSONSerialization.isValidJSONObject(e) { return e }
                else { return nil }
            }
        }

        if (self as? String) != nil || (self as? NSNumber) != nil { return self }

        let propertys = self.propertysNames()
        var dict: [String: Any] = [:]

        for key in propertys { dict[key] = self.value(forKey: key) }

        Mirror(reflecting: self).children.forEach { child in
            if let key = child.label {
                if let value = child.value as? MirrorProtocol { dict[key] = value.mirrorValue }
                else if JSONSerialization.isValidJSONObject(child.value) { dict[key] = child.value }
            }
        }
        return dict
    }

    // MARK: Private
    private static var cacheKeyDict: [String: [String]] = [:]

    private static func propertysNames() -> [String]? {
        let key = "\(self)"
        if let list = self.cacheKeyDict[key] { return list }

        var propertyNames: [String] = []
        let cls: AnyClass = self

        if cls == NSObject.self { return nil }

        var count: UInt32 = 0
        if let properties = class_copyPropertyList(cls, &count) {
            let intCount = Int(count)
            for i in 0 ..< intCount {
                let property = properties[i]
                let propertyName = String(cString: property_getName(property))
                propertyNames.append(propertyName)
            }
            free(properties)
        }
        if let tcls = self.superclass(), let list = (tcls as? NSObject.Type)?.propertysNames(), !list.isEmpty {
            propertyNames += list
        }
        let list = propertyNames.sorted()
        self.cacheKeyDict[key] = list
        return list
    }

    private func propertysNames() -> [String] {
        return Self.propertysNames() ?? []
    }
}

extension URL: MirrorProtocol {
    public var mirrorValue: Any? { self.absoluteString }
}

public protocol ExpressibleAllLiteral: MirrorProtocol { }

public extension ExpressibleAllLiteral {
    var mirrorValue: Any? { self }
}

extension Int: ExpressibleAllLiteral { }
extension Int8: ExpressibleAllLiteral { }
extension Int16: ExpressibleAllLiteral { }
extension Int32: ExpressibleAllLiteral { }
extension Int64: ExpressibleAllLiteral { }

extension Float: ExpressibleAllLiteral { }
extension CGFloat: ExpressibleAllLiteral { }

extension Double: ExpressibleAllLiteral { }

extension Decimal: ExpressibleAllLiteral { }

extension String: ExpressibleAllLiteral { }
extension Substring: ExpressibleAllLiteral { }
extension Character: ExpressibleAllLiteral { }

extension Bool: ExpressibleAllLiteral { }
