//
//  DispatchQueue+.swift
//
//  Created by xtinput on 2021/5/22.
//

import Foundation

public extension DispatchQueue {
    fileprivate static var _onceToken = [String]()

    class func xti_once(token: String = "\(#file):\(#function):\(#line)", block: () -> Void) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        if self._onceToken.contains(token) {
            return
        }
        self._onceToken.append(token)
        block()
    }
}
