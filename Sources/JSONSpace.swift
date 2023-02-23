//
//  JSONSpace.swift
//  DVTFoundation
//
//  Created by darvin on 2022/10/16.
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

public struct JSONBaseWrapper<BaseJSONType> {
    // MARK: Lifecycle
    public init(_ value: BaseJSONType) { self.base = value }

    // MARK: Public
    public var base: BaseJSONType
}

public protocol JSONNameSpace {
    associatedtype BaseJSONType
    static var dvtJson: BaseJSONType.Type { get }

    var dvtJson: BaseJSONType { set get }
}

public extension JSONNameSpace {
    static var dvtJson: JSONBaseWrapper<Self>.Type { JSONBaseWrapper.self }

    var dvtJson: JSONBaseWrapper<Self> { set { } get { JSONBaseWrapper(self) }}
}

public extension JSONBaseWrapper where BaseJSONType: MirrorProtocol {
    var json: Any? { self.base.mirrorValue }

    var string: String? { self.base.jsonString }
}

extension NSObject: JSONNameSpace { }
extension Array: JSONNameSpace { }
extension Dictionary: JSONNameSpace { }
extension Set: JSONNameSpace { }
extension String: JSONNameSpace { }

public extension JSONBaseWrapper where BaseJSONType == String {
    var json: Any? {
        if let data = self.base
            .data(using: .utf8) { return try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) }
        return nil
    }
}
