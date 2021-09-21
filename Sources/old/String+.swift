//
//  XTIString+.swift
//  XTIBaseFoundation
//
//  Created by xtinput on 2021/5/17.
//

import Foundation

public extension String {
    func xti_urlQueryEncoded() -> String {
        let characters = CharacterSet.urlQueryAllowed.intersection(CharacterSet(charactersIn: "!$&'()*+,;=:#[]@"))
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters: characters)
        return encodeUrlString ?? ""
    }

    func xti_regularValidate(_ regular: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regular)
        return predicate.evaluate(with: self)
    }
}
