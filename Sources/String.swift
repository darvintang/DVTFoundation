//
//  String.swift
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
import Security

extension String: NameSpace { }
public extension BaseWrapper where BaseType == String {
    /// 获取从`start`开始到`end`结束的`Range<String.Index>`
    ///
    /// 如果`start`或`end`不在范围内直接返回nil
    ///
    /// - Parameters:
    ///   - start: 开始的位置
    ///   - end: 结束的位置
    /// - Returns: 返回结果
    func range(_ start: Int, to end: Int) -> Range<String.Index>? {
        guard start >= 0, end >= start, end < self.base.count else {
            return nil
        }
        return Range<String.Index>(NSRange(location: start, length: end - start + 1), in: self.base)
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
    ///   - end: 结束的位置
    /// - Returns: 返回结果
    subscript(_ start: Int, to end: Int) -> String {
        guard end >= 0, end >= start, start < self.base.count else {
            return ""
        }
        let newStart = max(0, start)
        let newEnd = min(end, self.base.count - 1)
        guard newEnd >= newStart, let range = self.range(newStart, to: newEnd), !range.isEmpty else {
            return ""
        }
        return "\(self.base[range])"
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
        guard count > 0, start < self.base.count else {
            return ""
        }
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
        guard index >= 0, index < self.base.count else {
            return ""
        }
        var newIndex = self.base.startIndex
        self.base.formIndex(&newIndex, offsetBy: index)
        return "\(self.base[newIndex])"
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
    func replace(_ start: Int, to end: Int, with replacement: String) -> String {
        var res = self.base
        if let range = self.range(start, to: end) {
            res.replaceSubrange(range, with: replacement)
        }
        return res
    }

    /// 对字符串进行URLQuery编码，可以自己设定额外的忽略字符
    func urlQueryEncoded(in characters: String = "!$&'()*+,;=:#[]@") -> String {
        let characters = CharacterSet.urlQueryAllowed.intersection(CharacterSet(charactersIn: characters))
        let encodeUrlString = self.base.addingPercentEncoding(withAllowedCharacters: characters)
        return encodeUrlString ?? ""
    }

    /// 正则校验
    func regularValidate(_ regular: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regular)
        return predicate.evaluate(with: self.base)
    }
}

public extension BaseWrapper where BaseType == String {
    var md5: String {
        guard let digestData = self.base.data(using: .utf8)?.dvt.md5 else {
            return ""
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined().uppercased()
    }
}

public extension BaseWrapper where BaseType == String {
    /// 设置全局字符串加密的私钥，如果没有设置，每次加密需要传递公钥
    static var rsaPublic: String {
        set {
            Data.dvt.rsaPublic = newValue
        }
        get {
            Data.dvt.rsaPublic
        }
    }

    /// 设置全局字符串解密的私钥，如果没有设置，每次解密需要传递私钥
    static var rsaPrivate: String {
        set {
            Data.dvt.rsaPrivate = newValue
        }
        get {
            Data.dvt.rsaPrivate
        }
    }

    /// 校验RSA签名
    /// - Parameters:
    ///   - publicKey: 公钥
    ///   - signature: 签名
    ///   - algorithm: 签名类型
    /// - Returns: 结果
    func rsaVerify(_ publicKey: String = "", signature: String, algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA256) throws -> Bool {
        guard let signatureData = Data(base64Encoded: signature) else {
            throw RSAError.dataError(domain: "签名字符串异常")
        }
        guard let signedData = self.base.data(using: .utf8) else {
            throw RSAError.dataError(domain: "被签名字符串异常")
        }
        return try signedData.dvt.rsaVerify(publicKey, signature: signatureData, algorithm: algorithm)
    }

    /// 获取一个RSA签名
    /// - Parameters:
    ///   - privateKey: 私钥
    ///   - algorithm: 类型
    /// - Returns: 签名
    func rsaSigned(_ privateKey: String = "", algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA256) throws -> String {
        guard let signedData = self.base.data(using: .utf8) else {
            throw RSAError.dataError(domain: "被签名字符串异常")
        }
        let data = try signedData.dvt.rsaSigned(privateKey, algorithm: algorithm)
        return data.base64EncodedString()
    }

    /// 获取加密后的字符串
    /// - Parameter privateKey: 公钥
    /// - Returns: 加密后的结果
    func rsaEncrypt(_ publicKey: String = "", algorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1) throws -> String {
        guard let baseString = self.base.data(using: .utf8) else {
            throw RSAError.dataError(domain: "被加密字符串异常")
        }
        return try baseString.dvt.rsaEncrypt(publicKey, algorithm: algorithm).base64EncodedString()
    }

    /// 获取解密后的字符串
    /// - Parameter privateKey: 私钥
    /// - Returns: 解密后的结果
    func rsaDecrypt(_ privateKey: String = "", algorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1) throws -> String {
        guard let signedData = Data(base64Encoded: self.base, options: [.ignoreUnknownCharacters]) else {
            throw RSAError.dataError(domain: "被解密字符串异常")
        }
        let data = try signedData.dvt.rsaDecrypt(privateKey, algorithm: algorithm)
        guard let res = String(data: data, encoding: .utf8) else {
            throw RSAError.dataError(domain: "解密数据转字符串失败")
        }
        return res
    }
}
