//
//  NSObject.swift
//  DVTFoundation
//
//  Created by darvin on 2022/1/1.
//

import Foundation

public extension NSObject {
    static func swizzleSelector(_ origin: Selector, swizzle: Selector) {
        self.swizzleInstanceSelector(origin, swizzle: swizzle)
    }

    static func swizzleInstanceSelector(_ origin: Selector, swizzle: Selector) {
        if let originMethod = class_getInstanceMethod(self, origin),
           let swizzleMethod = class_getInstanceMethod(self, swizzle) {
            method_exchangeImplementations(originMethod, swizzleMethod)
        }
    }

    static func swizzleClassSelector(_ origin: Selector, swizzle: Selector) {
        if let originMethod = class_getClassMethod(self, origin),
           let swizzleMethod = class_getClassMethod(self, swizzle) {
            method_exchangeImplementations(originMethod, swizzleMethod)
        }
    }
}
