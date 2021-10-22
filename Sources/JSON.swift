//
//  File.swift
//
//
//  Created by darvintang on 2021/10/22.
//
/*

 MIT License

 Copyright (c) 2021 darvintang http://blog.tcoding.cn

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

public struct JSONBaseWrapper<BaseType> {
    public var base: BaseType
    public init(_ value: BaseType) {
        self.base = value
    }

    public var jsonString: String? {
        if self.base is String {
            return self.base as? String
        }
        guard let data = try? JSONSerialization.data(withJSONObject: self.base, options: []) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    public var json: Any? {
        if let value = self.base as? String {
            if let data = value.data(using: .utf8) {
                return try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
            }
        }
        return self.base
    }
}

public protocol JSONNameSpace {
    associatedtype BaseType
    var dvtJson: BaseType { set get }
    static var dvtJson: BaseType.Type { get }
}

public extension JSONNameSpace {
    var dvtJson: JSONBaseWrapper<Self> { set {} get { JSONBaseWrapper(self) }}
    static var dvtJson: JSONBaseWrapper<Self>.Type { JSONBaseWrapper.self }
}

extension Array: JSONNameSpace {}
extension Dictionary: JSONNameSpace {}
extension Set: JSONNameSpace {}
extension String: JSONNameSpace {}
