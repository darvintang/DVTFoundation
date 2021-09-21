//
//  String.swift
//
//
//  Created by darvintang on 2021/9/21.
//

import Foundation

extension String: NameSpace { }
public extension NameSpaceWrapper where BaseType == String {
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
}
