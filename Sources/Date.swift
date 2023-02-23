//
//  Date.swift
//  DVTFoundation
//
//  Created by darvin on 2021/9/23.
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

public extension DateFormatter {
    convenience init(dvt format: String) {
        self.init()
        self.dateFormat = format
        self.locale = Locale.current
    }
}

extension Date: NameSpace { }

public extension BaseWrapper where BaseType == Date {
    func string(of format: String = "yyyy-MM-dd") -> String { DateFormatter(dvt: format).string(from: self.base) }

    func addYear(_ number: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .year, value: number, to: self.base) ?? self.base.addingTimeInterval(3600 * 24 * 365)
    }

    func addMonth(_ number: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .month, value: number, to: self.base) ?? self.base.addingTimeInterval(3600 * 24 * 30)
    }

    func addWeek(_ number: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .weekday, value: number, to: self.base) ?? self.base.addingTimeInterval(3600 * 24 * 7)
    }

    func addDay(_ number: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: number, to: self.base) ?? self.base.addingTimeInterval(3600 * 24)
    }
}

public extension BaseWrapper where BaseType == String {
    func date(of format: String = "yyyy-MM-dd") -> Date? { DateFormatter(dvt: format).date(from: self.base) }
}
