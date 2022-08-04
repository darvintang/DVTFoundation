//
//  File 2.swift
//
//
//  Created by darvin on 2021/9/30.
//

/*

 MIT License

 Copyright (c) 2022 darvin http://blog.tcoding.cn

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

import CommonCrypto
import Foundation

extension Data: NameSpace {}

public extension BaseWrapper where DT == Data {
    var md5: Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digestData = Data(count: length)
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            self.base.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(self.base.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }

    var md5String: String {
        self.md5.map { String(format: "%02hhx", $0) }.joined().uppercased()
    }

    func string(_ encoding: String.Encoding = .utf8) -> String? {
        String(data: self.base, encoding: encoding)
    }

    var utf8String: String? {
        self.string()
    }
}
