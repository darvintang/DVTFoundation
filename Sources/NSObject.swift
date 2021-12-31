//
//  NSObject.swift
//
//
//  Created by darvin on 2022/1/1.
//

import UIKit

public extension NSObject {
    static func swizzleSelector(_ origin: Selector, swizzle: Selector) {
        if let originMethod = class_getInstanceMethod(self, origin),
           let swizzleMethod = class_getInstanceMethod(self, swizzle) {
            method_exchangeImplementations(originMethod, swizzleMethod)
        }
    }
}
