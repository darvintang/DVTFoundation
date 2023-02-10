//
//  GCDTimer.swift
//  DVTFoundation
//
//  Created by darvin on 2021/10/20.
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

/// 基于`DispatchSourceTimer`的计时器
///
/// 将`interval`设置为`.never`或小于`0.0001`和`asyncAfter`效果类似
///
///     let value = Objective()
///     let timer = GCDTimer(queue: self.queue, repeating: 0.5) {
///         print(value)
///     }
///     for _ in 0 ... 1000 {
///         DispatchQueue.global().async {
///             switch arc4random() % 5 {
///                 case 0:
///                     timer.activate()
///                 case 1:
///                     timer.suspend()
///                 case 2:
///                     timer.resume()
///                 case 3:
///                     timer.cancel()
///                 default:
///                     timer.reload()
///             }
///         }
///     }
/// 该段代码为多线程暴力测试示范，时间的精准性没测试
open class GCDTimer {
    private var mutex: pthread_mutex_t
    /// 计时器状态
    public private(set) var status: Status = .un

    private let queue: DispatchQueue

    private let deadline: DispatchTime
    /// 时间间隔
    public let interval: DispatchTimeInterval
    /// 计时器注册时执行的任务
    public var registrationHandler: (() -> Void)?
    /// 计时器任务
    private let workItem: DispatchWorkItem
    /// 计时器取消时执行的任务
    public var cancelHandler: (() -> Void)?

    private var source: DispatchSourceTimer?

    public enum Status {
        case un, inited, activate, suspend, cancel
    }

    /// 初始化一个计时器
    /// - Parameters:
    ///   - queue: 计时器任务执行的队列
    ///   - deadline: 延迟时间
    ///   - interval: 时间间隔，秒
    ///   - activate: 是否自动开启
    ///   - workItem: 任务
    public convenience init(queue: DispatchQueue = .main, deadline: DispatchTime = .now(), repeating interval: Double, auto activate: Bool = true, workItem: DispatchWorkItem) {
        let milliseconds = Int(interval * 1000)
        let Tinterval: DispatchTimeInterval = milliseconds <= 0 ? .never : .milliseconds(milliseconds)
        self.init(queue: queue, deadline: deadline, repeating: Tinterval, auto: activate, workItem: workItem)
    }

    /// 初始化一个计时器
    /// - Parameters:
    ///   - queue: 计时器任务执行的队列
    ///   - deadline: 延迟时间
    ///   - interval: 时间间隔，秒
    ///   - activate: 是否自动开启
    ///   - eventHandler: 任务
    public convenience init(queue: DispatchQueue = .main, deadline: DispatchTime = .now(), repeating interval: Double, auto activate: Bool = true, eventHandler: @escaping () -> Void) {
        let milliseconds = Int(interval * 1000)
        let Tinterval: DispatchTimeInterval = milliseconds <= 0 ? .never : .milliseconds(milliseconds)
        self.init(queue: queue, deadline: deadline, repeating: Tinterval, auto: activate, eventHandler: eventHandler)
    }

    /// 初始化一个计时器
    /// - Parameters:
    ///   - queue: 计时器任务执行的队列
    ///   - deadline: 延迟时间
    ///   - interval: 时间间隔，DispatchTimeInterval类型
    ///   - activate: 是否自动开启
    ///   - eventHandler: 任务
    public convenience init(queue: DispatchQueue = .main, deadline: DispatchTime = .now(), repeating interval: DispatchTimeInterval = .never, auto activate: Bool = true, eventHandler: @escaping () -> Void) {
        let item = DispatchWorkItem(block: eventHandler)
        self.init(queue: queue, deadline: deadline, repeating: interval, auto: activate, workItem: item)
    }

    /// 初始化一个计时器
    /// - Parameters:
    ///   - queue: 计时器任务执行的队列
    ///   - deadline: 延迟时间
    ///   - interval: 时间间隔，DispatchTimeInterval类型
    ///   - activate: 是否自动开启
    ///   - workItem: 任务
    public init(queue: DispatchQueue = .main, deadline: DispatchTime = .now(), repeating interval: DispatchTimeInterval = .never, auto activate: Bool = true, workItem: DispatchWorkItem) {
        self.queue = queue
        self.interval = interval
        self.workItem = workItem
        self.mutex = pthread_mutex_t()
        self.deadline = deadline
        var attr = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
        pthread_mutex_init(&self.mutex, &attr)
        pthread_mutexattr_destroy(&attr)
        self.reload(activate)
    }

    /// 启动计时器，只有计时器在`inited`状态有效
    public func activate() {
        pthread_mutex_lock(&self.mutex)
        defer {
            pthread_mutex_unlock(&self.mutex)
        }
        if self.status == .inited {
            self.source?.activate()
            self.status = .activate
        }
    }

    /// 暂停计时器，只有计时器在`activate`状态有效
    public func suspend() {
        pthread_mutex_lock(&self.mutex)
        defer {
            pthread_mutex_unlock(&self.mutex)
        }
        if self.status == .activate {
            self.source?.suspend()
            self.status = .suspend
        }
    }

    /// 恢复计时器，只有计时器在`suspend`状态有效
    public func resume() {
        pthread_mutex_lock(&self.mutex)
        defer {
            pthread_mutex_unlock(&self.mutex)
        }
        if self.status == .suspend {
            self.source?.resume()
            self.status = .activate
        }
    }

    /// 取消计时器，计时器在`activate`和`suspend`状态有效
    public func cancel() {
        pthread_mutex_lock(&self.mutex)
        defer {
            pthread_mutex_unlock(&self.mutex)
        }

        if self.status == .activate || self.status == .suspend {
            self.resume()
            self.source?.cancel()
            self.status = .cancel
        }
    }

    /// 重置计时器
    ///
    /// 在计时器状态不是`inited`的时候，可以重置一个计时器，如果状态为`cancel`，计时器重置`deadline`参数为`.now()`
    ///
    /// - Parameter auto: 是否自动开启
    public func reload(_ auto: Bool = false) {
        pthread_mutex_lock(&self.mutex)
        defer {
            pthread_mutex_unlock(&self.mutex)
        }
        guard self.status != .inited else {
            return
        }

        if self.interval == .never {
            self.cancel()
            self.status = .un
        }

        guard self.status == .un || self.status == .cancel else {
            return
        }

        if self.source != nil {
            self.source = nil
        }

        self.source = DispatchSource.makeTimerSource(flags: [.strict], queue: self.queue)
        self.source?.schedule(deadline: self.status == .cancel ? .now() : self.deadline, repeating: self.interval, leeway: .nanoseconds(0))

        self.source?.setEventHandler(handler: self.workItem)
        self.source?.setRegistrationHandler { [weak self] in
            self?.registrationHandler?()
        }
        self.source?.setCancelHandler { [weak self] in
            self?.cancelHandler?()
        }
        self.status = .inited
        if auto {
            self.activate()
        }
    }

    deinit {
        self.activate()
        self.cancel()
        if self.source != nil {
            self.source = nil
        }
        pthread_mutex_destroy(&self.mutex)
    }
}

extension GCDTimer {
    /// 初始化一个计时器
    /// - Parameters:
    ///   - queue: 计时器任务执行的队列
    ///   - deadline: 延迟时间, 秒
    ///   - workItem: 任务
    public convenience init(queue: DispatchQueue = .main, deadline: TimeInterval, workItem: DispatchWorkItem) {
        self.init(queue: queue, deadline: .now() + deadline, repeating: .never, auto: true, workItem: workItem)
    }

    /// 初始化一个计时器
    /// - Parameters:
    ///   - queue: 计时器任务执行的队列
    ///   - deadline: 延迟时间, 秒
    ///   - eventHandler: 任务
    public convenience init(queue: DispatchQueue = .main, deadline: TimeInterval, eventHandler: @escaping () -> Void) {
        self.init(queue: queue, deadline: .now() + deadline, repeating: .never, auto: true, eventHandler: eventHandler)
    }
}
