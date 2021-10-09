//
//  NameSpaceWrapper.swift
//
//
//  Created by darvintang on 2021/9/21.
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

public struct BaseWrapper<BaseType> {
    public var base: BaseType
    public init(_ value: BaseType) {
        self.base = value
    }
}

public protocol NameSpace {
    associatedtype BaseType
    var dvt: BaseType { set get }
    static var dvt: BaseType.Type { get }
}

public extension NameSpace {
    var dvt: BaseWrapper<Self> { set {} get { BaseWrapper(self) }}

    static var dvt: BaseWrapper<Self>.Type { BaseWrapper.self }
}