//
//  DispatchQueue+.swift
//
//
//  Created by darvin on 2021/5/22.
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

import Foundation

extension DispatchQueue: NameSpace {}

private var DispatchQueue_onceIdentifier = [String]()

public extension BaseWrapper where DT == DispatchQueue {
    static func once(_ identifier: String = "\(#file):\(#function):\(#line)", block: () -> Void) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        if DispatchQueue_onceIdentifier.contains(identifier) {
            return
        }
        DispatchQueue_onceIdentifier.append(identifier)
        block()
    }

    @discardableResult static func mainAfter(deadline time: Double, block: @escaping () -> Void) -> DispatchWorkItem {
        return DispatchQueue.main.dvt.after(deadline: time, block: block)
    }

    @discardableResult func after(deadline time: Double, block: @escaping () -> Void) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: block)
        let deadline = DispatchTime.now() + .milliseconds(Int(time * 1000))
        self.base.asyncAfter(deadline: deadline, execute: item)
        return item
    }
}
