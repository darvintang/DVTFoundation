//
//  XTIDate+.swift
//  XTIBaseTool
//
//  Created by xtinput on 2021/5/8.
//

import Foundation

public extension DateFormatter {
    convenience init(xti format: String) {
        self.init()
        self.dateFormat = format
    }
}
