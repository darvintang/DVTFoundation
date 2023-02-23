//
//  NSObject.swift
//  DVTFoundation
//
//  Created by darvin on 2022/1/1.
//

import Foundation
import ObjectiveC

public extension NSObject {
    @available(*, unavailable, renamed: "dvt_swizzleInstanceSelector(_:swizzle:)", message: "请使用dvt_swizzleInstanceSelector(_:swizzle:)")
    static func dvt_swizzleSelector(_ origin: Selector, swizzle: Selector) {
        self.dvt_swizzleInstanceSelector(origin, swizzle: swizzle)
    }

    static func dvt_swizzleInstanceSelector(_ origin: Selector, swizzle: Selector) {
        if let originMethod = class_getInstanceMethod(self, origin),
           let swizzleMethod = class_getInstanceMethod(self, swizzle) {
            method_exchangeImplementations(originMethod, swizzleMethod)
        }
    }

    static func dvt_swizzleClassSelector(_ origin: Selector, swizzle: Selector) {
        if let originMethod = class_getClassMethod(object_getClass(self), origin),
           let swizzleMethod = class_getClassMethod(object_getClass(self), swizzle) {
            method_exchangeImplementations(originMethod, swizzleMethod)
        }
    }

    static func dvt_printInstancePropertys(_ cls: AnyClass? = nil) {
        var propertyNames: [String] = []

        var count: UInt32 = 0
        if let properties = class_copyPropertyList(cls ?? self, &count) {
            let intCount = Int(count)
            for i in 0 ..< intCount {
                let property = properties[i]
                let propertyName = String(cString: property_getName(property))
                propertyNames.append(propertyName)
            }
            free(properties)
        }
        print(propertyNames)
    }

    static func dvt_printClassMethods(_ cls: AnyClass? = nil) {
        var methodNames: [String] = []

        var count: UInt32 = 0
        if let methodList = class_copyMethodList(object_getClass(cls ?? self), &count) {
            let intCount = Int(count)
            for i in 0 ..< intCount {
                let method = methodList[i]
                methodNames.append(NSStringFromSelector(method_getName(method)))
            }
            free(methodList)
        }
        print(methodNames)
    }

    static func dvt_printInstanceMethods(_ cls: AnyClass? = nil) {
        var methodNames: [String] = []

        var count: UInt32 = 0
        if let methodList = class_copyMethodList(cls ?? self, &count) {
            let intCount = Int(count)
            for i in 0 ..< intCount {
                let method = methodList[i]
                methodNames.append(NSStringFromSelector(method_getName(method)))
            }
            free(methodList)
        }
        print(methodNames)
    }
}
