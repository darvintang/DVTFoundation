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

private extension NSException {
    typealias NSExceptionrRaiseCompletionBlock = (_ exception: NSException) -> Void

    static var NSException_DVTFoundation_raiseCompletionBlock_key: UInt8 = 0
    static var NSException_DVTFoundation_Swizzleed_flag = false

    static var raiseCompletionBlock: NSExceptionrRaiseCompletionBlock? {
        set { objc_setAssociatedObject(self, &self.NSException_DVTFoundation_raiseCompletionBlock_key, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
        get { objc_getAssociatedObject(self, &self.NSException_DVTFoundation_raiseCompletionBlock_key) as? NSExceptionrRaiseCompletionBlock }
    }

    static var shutRaise = false {
        didSet { self.foundation_swizzleed() }
    }

    static func foundation_swizzleed() {
        if self.NSException_DVTFoundation_Swizzleed_flag { return }
        defer { self.NSException_DVTFoundation_Swizzleed_flag = true }
        self.dvt_swizzleInstanceSelector(NSSelectorFromString("raise"), swizzle: #selector(dvt_foundation_raise))
    }

    @objc func dvt_foundation_raise() {
        if !Self.shutRaise { self.dvt_foundation_raise() }
        else { Self.raiseCompletionBlock?(self) }
    }
}

extension NSException: NameSpace { }

public extension BaseWrapper where BaseType: NSException {
    /// 拦截系统中断，可以用于UIKit操作私有属性的时候异常拦截
    ///
    /// completion并不是一定会执行，如果多个地方同时设置completion就会出现不执行的情况
    static func ignore(_ handler: () -> Void, completion: ((_ exception: NSException) -> Void)? = nil) {
        NSException.shutRaise = true
        if completion != nil { NSException.raiseCompletionBlock = completion }
        handler()
        NSException.shutRaise = false
        // 如果0.1秒之后还没有报异常就清理掉
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { NSException.raiseCompletionBlock = nil }
    }
}
