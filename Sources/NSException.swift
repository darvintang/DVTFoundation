//
//  NSException.swift
//  DVTFoundation
//
//  Created by darvin on 2023/2/10.
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

fileprivate typealias NSExceptionrRaiseCompletionBlock = (_ exception: NSException) -> Void

fileprivate extension NSException {
    static var NSException_Monitor_Key: UInt8 = 0
    static var raiseCompletionBlock: NSExceptionrRaiseCompletionBlock? {
        set {
            objc_setAssociatedObject(self, &self.NSException_Monitor_Key, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &self.NSException_Monitor_Key) as? NSExceptionrRaiseCompletionBlock
        }
    }

    static var shutRaise = false {
        didSet {
            self.swizzleed()
        }
    }

    static var NSException_DVTFoundation_Swizzleed = false
    static func swizzleed() {
        if self.NSException_DVTFoundation_Swizzleed {
            return
        }
        self.swizzleInstanceSelector(NSSelectorFromString("raise"), swizzle: #selector(dvt_raise))
        self.NSException_DVTFoundation_Swizzleed = true
    }

    @objc func dvt_raise() {
        if !Self.shutRaise {
            self.dvt_raise()
        } else {
            Self.raiseCompletionBlock?(self)
        }
    }
}

extension NSException: NameSpace { }

public extension BaseWrapper where BaseType: NSException {
    /// 拦截系统中断，可以用于UIKit操作私有属性的时候异常拦截
    static func ignoreHandler(_ handler: () -> Void, completion: ((_ exception: NSException) -> Void)? = nil) {
        NSException.shutRaise = true
        NSException.raiseCompletionBlock = completion
        handler()
        NSException.shutRaise = false
    }
}
