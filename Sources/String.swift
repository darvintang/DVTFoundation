//
//  String.swift
//  DVTFoundation
//
//  Created by darvin on 2021/9/21.
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

extension String: NameSpace { }

public extension BaseWrapper where BaseType == String {
    /// NSString.length
    var nsCount: Int { (self.base as NSString).length }

    var isPhone: Bool {
        self.regularValidate("^1(3\\d|4[5-9]|5[0-35-9]|6[2567]|7[0-8]|8\\d|9[0-35-9])\\d{8}$")
    }

    /// 字符串是空白的
    var isBlank: Bool {
        self.base.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 获取从`start`开始到`end`结束(包含)的`Range<String.Index>`
    ///
    /// 如果`start`或`end`不在范围内直接返回nil
    ///
    /// - Parameters:
    ///   - start: 开始的位置
    ///   - end: 结束的位置，包含
    /// - Returns: 返回结果
    func range(_ start: Int, to end: Int) -> Range<String.Index>? {
        guard start >= 0, end >= start, end < self.base.count else { return nil }
        return Range<String.Index>(uncheckedBounds: (lower: self.base.index(self.base.startIndex, offsetBy: start),
                                                     upper: self.base.index(self.base.startIndex, offsetBy: end + 1)))
    }

    /// 获取从`start`开始到`end`结束的字符串
    ///
    /// 首先判断`start`和`end`的合法性，`end >= 0 && end >= start && start < self.base.count`；
    /// 然后做越界处理得到新的`newStart`和`newEnd`，通过`newEnd - newStart + 1`来获取目标字符串长度；
    /// 利用`NSRange`初始化一个`Range<String.Index>`；
    /// 然后通过`Range<String.Index>`拿到目标字符串
    ///
    /// - Parameters:
    ///   - start: 开始的位置
    ///   - end: 结束的位置，包含
    /// - Returns: 返回结果
    subscript(_ start: Int, to end: Int) -> String {
        guard end >= 0, end >= start, start < self.base.count else { return "" }
        let newStart = max(0, start)
        let newEnd = min(end, self.base.count - 1)
        guard newEnd >= newStart, let range = self.range(newStart, to: newEnd), !range.isEmpty else { return "" }
        return "\(self.base[range])"
    }

    /// 获取从`start`开始到`end`字符串出现的位置的字符串
    ///
    /// 首先利用components获取新的字符串；
    /// 然后新字符串长度减去`start`得到目标字符串长度；
    /// 通过`suffix(length)`获取目标字符串
    ///
    /// - Parameters:
    ///   - start: 开始的位置
    ///   - end: 结束的位置
    /// - Returns: 返回结果
    subscript(_ start: Int, to end: String) -> String {
        let string = self.base.components(separatedBy: end).first ?? self.base
        let length = max(0, string.count - start)
        if length == 0 { return "" }
        return "\(string.suffix(length))"
    }

    /// 获取从`start`开始的`count`长度的字符串
    ///
    /// 如果`start`不在范围内或者`count <= 0`，返回一个空字符串
    /// 否则计算`end`的位置调用`subscript(_:to:)`获取
    ///
    /// - Parameters:
    ///   - start: 开始的位置
    ///   - count: 长度
    /// - Returns: 返回结果
    subscript(_ start: Int, length count: Int) -> String {
        guard count > 0, start < self.base.count else { return "" }
        let newStart = max(0, start)
        return self[newStart, to: newStart + count - 1]
    }

    /// 获取`index`位置的字符串
    ///
    /// 利用`index(_:offsetBy:)`获取到指定位置的`String.Index`，然后直接通过下标获取结果
    /// 如果`index`不在范围内，返回一个空字符串
    ///
    /// - Parameters:
    ///   - index: 指定的位置
    /// - Returns: 返回结果
    /// - Complexity: O(*n*)
    subscript(_ index: Int) -> String {
        guard index >= 0, index < self.base.count else { return "" }
        return "\(self.base[self.base.index(self.base.startIndex, offsetBy: index)])"
    }

    /// 将字符串插入到`index`
    ///
    /// 从`index`位置将原字符串分割为`left`和`right`，然后拼接成新的字符串。
    /// 如果`index`不在范围内，会插入到最前面(`index < 0`)或最后面(`index >= count`)
    ///
    /// - Parameters:
    ///   - newElement: 需要插入的字符串结果
    ///   - index: 需要插入的位置，已经做了越界处理
    /// - Returns: 返回结果
    /// - Complexity: O(*n*)，主要是确定index的位置需要的时间
    @discardableResult func insert(_ newElement: String, at index: Int) -> String {
        let newIndex = min(max(0, index), self.base.count)
        let left = self.base.prefix(newIndex)
        let right = self.base.suffix(from: self.base.index(self.base.startIndex, offsetBy: newIndex))
        return left + newElement + right
    }

    /// 字符串替换
    /// - Parameters:
    ///   - start: 需要替换的字符串起始位置
    ///   - end: 需要替换的字符串结束位置
    ///   - replacement: 替换字符串
    /// - Returns: 替换后的字符串
    func replacing(_ start: Int, to end: Int, with replacement: String) -> String {
        var res = self.base
        if let range = self.range(start, to: end) { res.replaceSubrange(range, with: replacement) }
        return res
    }

    /// 字符串替换
    /// - Parameters:
    ///   - start: 需要替换的字符串起始位置
    ///   - end: 需要替换的字符串结束位置
    ///   - replacement: 替换字符串
    /// - Returns: 替换后的字符串
    func replacing(_ start: Int, length count: Int, with replacement: String) -> String {
        self.replacing(start, to: start + count - 1, with: replacement)
    }

    /// 字符串替换
    /// - Parameters:
    ///   - of: 需要替换的字符串
    ///   - replacement: 替换字符串
    /// - Returns: 替换后的字符串
    func replacing(_ of: String, with replacement: String) -> String {
        self.base.replacingOccurrences(of: of, with: replacement)
    }

    /// 对字符串进行URLQuery编码，可以自己设定额外的忽略字符
    func urlQueryEncoded(in characters: String = "!$&'()*+,;=:#[]@") -> String {
        let characters = CharacterSet.urlQueryAllowed.intersection(CharacterSet(charactersIn: characters))
        let encodeURLString = self.base.addingPercentEncoding(withAllowedCharacters: characters)
        return encodeURLString ?? ""
    }

    /// 正则校验
    func regularValidate(_ regular: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regular)
        return predicate.evaluate(with: self.base)
    }
}

public extension BaseWrapper where BaseType == String {
    var pinyin: String {
        let mutableString = NSMutableString(string: self.base)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let string = String(mutableString)
        return string
    }

    var reverse: String {
        var resstr = ""
        self.base.forEach { c in resstr = "\(c)" + resstr }
        return resstr
    }
}

public extension BaseWrapper where BaseType == String {
    /// base64编码，编码失败返回nil
    var base64: String? { self.base.data(using: .utf8)?.base64EncodedString() }

    /// base64解码，解码失败返回nil
    var string: String? {
        guard let data = self.base64Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

public extension BaseWrapper where BaseType == String {
    @available(iOS, introduced: 2.0, deprecated: 13.0, message: "md5已经被系统标记为不安全，请使用sha256")
    var md5: String? { self.base.data(using: .utf8)?.dvt.md5String }

    var sha256: String? { self.base.data(using: .utf8)?.dvt.sha256String }
}

public extension BaseWrapper where BaseType == String {
    var base64Data: Data? { Data(base64Encoded: self.base) }
}

public extension BaseWrapper where BaseType == String {
    var url: URL? { URL(string: self.base) }
}

extension Substring: NameSpace { }
public extension BaseWrapper where BaseType == Substring {
    var string: String { String(self.base) }
}
