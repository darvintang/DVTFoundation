//
//  Array.swift
//  DVTFoundation
//
//  Created by darvin on 2022/1/19.
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

public extension Array {
    @discardableResult
    mutating func dvt_remove(_ element: Element) -> Element? where Element: Equatable {
        if let index = self.firstIndex(of: element) {
            return self.remove(at: index)
        }
        return nil
    }

    @discardableResult
    mutating func dvt_remove(where element: (Element) -> Bool) -> Element? {
        if let index = self.firstIndex(where: element) {
            return self.remove(at: index)
        }
        return nil
    }
}

public struct ArraySpace<Element> {
    fileprivate var base: [Element]
}

extension ArraySpace {
}

extension Array {
    public var dvt: ArraySpace<Element> {
        ArraySpace(base: self)
    }
}
