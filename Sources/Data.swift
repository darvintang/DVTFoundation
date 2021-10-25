//
//  File 2.swift
//
//
//  Created by darvintang on 2021/9/30.
//

import Foundation

import CommonCrypto.CommonDigest
import Security.SecKey

extension Data: NameSpace {}

public extension BaseWrapper where DT == Data {
    var md5: Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digestData = Data(count: length)
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            self.base.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(self.base.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }

    var md5String: String {
        return self.md5.map { String(format: "%02hhx", $0) }.joined().uppercased()
    }
}

public extension BaseWrapper where DT == Data {
    /// 设置全局字符串加密的私钥，如果没有设置，每次加密需要传递公钥
    static var rsaPublic: String {
        set {
            rsa.rsaPublic = newValue
        }
        get {
            rsa.rsaPublic
        }
    }

    /// 设置全局字符串解密的私钥，如果没有设置，每次解密需要传递私钥
    static var rsaPrivate: String {
        set {
            rsa.rsaPrivate = newValue
        }
        get {
            rsa.rsaPrivate
        }
    }

    /// 校验一个签名
    /// - Parameters:
    ///   - publicKey: 公钥
    ///   - signature: 签名
    ///   - algorithm: 签名类型
    /// - Returns: 结果
    func rsaVerify(_ publicKey: String = "", signature: Data, algorithm: SecKeyAlgorithm = .rsaSignatureDigestPKCS1v15SHA1) throws -> Bool {
        guard !publicKey.isEmpty || !Self.rsaPublic.isEmpty else {
            throw RSAError.encryptError(domain: "公钥不能为空")
        }
        var tempRSA = publicKey.isEmpty ? rsa : RSA(rsaPublic: publicKey)
        return try tempRSA.rsaVerify(self.base, signature: signature, algorithm: algorithm)
    }

    /// 获取一个RSA签名
    /// - Parameters:
    ///   - privateKey: 私钥
    ///   - algorithm: 签名类型
    /// - Returns: 签名
    func rsaSigned(_ privateKey: String = "", algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA1) throws -> Data {
        guard !privateKey.isEmpty || !Self.rsaPrivate.isEmpty else {
            throw RSAError.decryptError(domain: "私钥不能为空")
        }
        var tempRSA = privateKey.isEmpty ? rsa : RSA(rsaPrivate: privateKey)
        return try tempRSA.rsaSigned(self.base, algorithm: algorithm)
    }

    /// 获取加密后的数据
    /// - Parameter privateKey: 公钥
    /// - Returns: 加密后的结果
    func rsaEncrypt(_ publicKey: String = "", algorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1) throws -> Data {
        guard !publicKey.isEmpty || !Self.rsaPublic.isEmpty else {
            throw RSAError.encryptError(domain: "公钥不能为空")
        }
        var tempRSA = publicKey.isEmpty ? rsa : RSA(rsaPublic: publicKey)
        return try tempRSA.encrypt(self.base, algorithm: algorithm)
    }

    /// 获取解密后的数据
    /// - Parameter privateKey: 私钥
    /// - Returns: 解密后的结果
    func rsaDecrypt(_ privateKey: String = "", algorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1) throws -> Data {
        guard !privateKey.isEmpty || !Self.rsaPrivate.isEmpty else {
            throw RSAError.decryptError(domain: "私钥不能为空")
        }
        var tempRSA = privateKey.isEmpty ? rsa : RSA(rsaPrivate: privateKey)
        return try tempRSA.decrypt(self.base, algorithm: algorithm)
    }
}

private struct RSA {
    var rsaPublic = ""
    var rsaPrivate = ""

    var publicSecKey: SecKey?
    var privateSecKey: SecKey?

    mutating func rsaVerify(_ value: Data, signature: Data, algorithm: SecKeyAlgorithm) throws -> Bool {
        if signature.isEmpty {
            throw RSAError.dataError(domain: "签名不能为空")
        }
        if self.publicSecKey == nil {
            self.publicSecKey = try self.getRSAKey(self.rsaPublic, isPublic: true)
        }
        guard let secKey = self.publicSecKey else {
            throw RSAError.verifyError(domain: "公钥格式错误")
        }
        var error: Unmanaged<CFError>?
        let res = SecKeyVerifySignature(secKey, algorithm, value as CFData, signature as CFData, &error)
        guard error == nil else {
            throw RSAError.verifyError(domain: error?.takeUnretainedValue().localizedDescription ?? "数据异常")
        }
        return res
    }

    mutating func rsaSigned(_ value: Data, algorithm: SecKeyAlgorithm) throws -> Data {
        if self.privateSecKey == nil {
            self.privateSecKey = try self.getRSAKey(self.rsaPrivate, isPublic: false)
        }
        guard let secKey = self.privateSecKey else {
            throw RSAError.signatureError(domain: "私钥格式错误")
        }
        var error: Unmanaged<CFError>?
        guard let resData = SecKeyCreateSignature(secKey, algorithm, value as CFData, &error) as Data?, error == nil else {
            throw RSAError.signatureError(domain: error?.takeUnretainedValue().localizedDescription ?? "数据异常")
        }
        return resData
    }

    mutating func encrypt(_ value: Data, algorithm: SecKeyAlgorithm) throws -> Data {
        if self.publicSecKey == nil {
            self.publicSecKey = try self.getRSAKey(self.rsaPublic, isPublic: true)
        }
        guard let secKey = self.publicSecKey else {
            throw RSAError.encryptError(domain: "公钥格式错误")
        }
        var error: Unmanaged<CFError>?

        guard let resData = SecKeyCreateEncryptedData(secKey, algorithm, value as CFData, &error) as Data?, error == nil else {
            throw RSAError.encryptError(domain: error?.takeUnretainedValue().localizedDescription ?? "数据异常")
        }
        return resData
    }

    mutating func decrypt(_ value: Data, algorithm: SecKeyAlgorithm) throws -> Data {
        if self.privateSecKey == nil {
            self.privateSecKey = try self.getRSAKey(self.rsaPrivate, isPublic: false)
        }
        guard let secKey = self.privateSecKey else {
            throw RSAError.decryptError(domain: "私钥格式错误")
        }
        var error: Unmanaged<CFError>?
        guard let resData = SecKeyCreateDecryptedData(secKey, algorithm, value as CFData, &error) as Data?, error == nil else {
            throw RSAError.decryptError(domain: error?.takeUnretainedValue().localizedDescription ?? "数据异常")
        }
        return resData
    }

    func checkRSAKey(_ key: String) throws -> Data {
        let list = key.components(separatedBy: "\n").filter { !$0.hasPrefix("-----BEGIN") && !$0.hasPrefix("-----END") }
        guard !list.isEmpty else {
            throw RSAError.initError(domain: "密钥为空")
        }
        let newKeyString = list.joined(separator: "")
        guard let keyData = Data(base64Encoded: newKeyString, options: [.ignoreUnknownCharacters]) else {
            throw RSAError.initError(domain: "密钥格式不正确")
        }
        return keyData
    }

    func getRSAKey(_ keyString: String, isPublic: Bool) throws -> SecKey? {
        let keyData = try self.checkRSAKey(keyString)
        return try self.getRSAKey(keyData, isPublic: isPublic)
    }

    func getRSAKey(_ keyData: Data, isPublic: Bool) throws -> SecKey? {
        do {
            let newKeyData = try Self.stripKeyHeader(keyData: keyData)
            let keyClass = isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate
            let sizeInBits = newKeyData.count * 8
            let keyDict: [CFString: Any] = [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass: keyClass,
                kSecAttrKeySizeInBits: NSNumber(value: sizeInBits),
                kSecReturnPersistentRef: true,
            ]
            var error: Unmanaged<CFError>?
            guard let key = SecKeyCreateWithData(newKeyData as CFData, keyDict as CFDictionary, &error) else {
                throw RSAError.initError(domain: "密钥创建失败")
            }
            return key
        } catch {
            throw RSAError.initError(domain: "密钥序列化失败")
        }
    }

    static func stripKeyHeader(keyData: Data) throws -> Data {
        let node: Asn1Parser.Node
        do {
            node = try Asn1Parser.parse(data: keyData)
        } catch {
            throw RSAError.initError(domain: "密钥处理失败")
        }
        guard case let .sequence(nodes) = node else {
            throw RSAError.initError(domain: "密钥处理失败")
        }
        let onlyHasIntegers = nodes.filter { node -> Bool in
            if case .integer = node { return false }
            return true
        }.isEmpty

        if onlyHasIntegers { return keyData }
        if let last = nodes.last, case let .bitString(data) = last { return data }
        if let last = nodes.last, case let .octetString(data) = last { return data }
        throw RSAError.initError(domain: "密钥处理失败")
    }
}

private var rsa = RSA()

public enum RSAError: Error {
    case initError(domain: String)
    case dataError(domain: String)
    case signatureError(domain: String)
    case verifyError(domain: String)
    case encryptError(domain: String)
    case decryptError(domain: String)

    public var domain: String {
        switch self {
            case let .initError(domain):
                return "初始化失败：\(domain)"
            case let .encryptError(domain):
                return "加密失败：\(domain)"
            case let .decryptError(domain):
                return "解密失败：\(domain)"
            case let .signatureError(domain: domain):
                return "签名创建失败：\(domain)"
            case let .verifyError(domain: domain):
                return "签名验证失败：\(domain)"
            case let .dataError(domain: domain):
                return "数据异常：\(domain)"
        }
    }
}

private class Scanner {
    enum ScannerError: Error {
        case outOfBounds
    }

    let data: Data
    var index: Int = 0
    var isComplete: Bool {
        return self.index >= self.data.count
    }

    init(data: Data) {
        self.data = data
    }

    func consume(length: Int) throws -> Data {
        guard length > 0 else {
            return Data()
        }
        guard self.index + length <= self.data.count else {
            throw ScannerError.outOfBounds
        }
        let subdata = self.data.subdata(in: self.index ..< self.index + length)
        self.index += length
        return subdata
    }

    func consumeLength() throws -> Int {
        let lengthByte = try consume(length: 1).firstByte
        guard lengthByte >= 0x80 else {
            return Int(lengthByte)
        }
        let nextByteCount = lengthByte - 0x80
        let length = try consume(length: Int(nextByteCount))
        return length.integer
    }
}

private extension Data {
    var firstByte: UInt8 {
        var byte: UInt8 = 0
        copyBytes(to: &byte, count: MemoryLayout<UInt8>.size)
        return byte
    }

    var integer: Int {
        guard count > 0 else {
            return 0
        }
        var int: UInt32 = 0
        var offset: Int32 = Int32(count - 1)
        forEach { byte in
            let byte32 = UInt32(byte)
            let shifted = byte32 << (UInt32(offset) * 8)
            int = int | shifted
            offset -= 1
        }
        return Int(int)
    }
}

private enum Asn1Parser {
    enum Node {
        case sequence(nodes: [Node])
        case integer(data: Data)
        case objectIdentifier(data: Data)
        case null
        case bitString(data: Data)
        case octetString(data: Data)
    }

    enum ParserError: Error {
        case noType
        case invalidType(value: UInt8)
    }

    static func parse(data: Data) throws -> Node {
        let scanner = Scanner(data: data)
        let node = try parseNode(scanner: scanner)
        return node
    }

    static func parseNode(scanner: Scanner) throws -> Node {
        let firstByte = try scanner.consume(length: 1).firstByte

        if firstByte == 0x30 {
            let length = try scanner.consumeLength()
            let data = try scanner.consume(length: length)
            let nodes = try parseSequence(data: data)
            return .sequence(nodes: nodes)
        }

        if firstByte == 0x02 {
            let length = try scanner.consumeLength()
            let data = try scanner.consume(length: length)
            return .integer(data: data)
        }

        if firstByte == 0x06 {
            let length = try scanner.consumeLength()
            let data = try scanner.consume(length: length)
            return .objectIdentifier(data: data)
        }

        if firstByte == 0x05 {
            _ = try scanner.consume(length: 1)
            return .null
        }
        if firstByte == 0x03 {
            let length = try scanner.consumeLength()
            _ = try scanner.consume(length: 1)
            let data = try scanner.consume(length: length - 1)
            return .bitString(data: data)
        }

        if firstByte == 0x04 {
            let length = try scanner.consumeLength()
            let data = try scanner.consume(length: length)
            return .octetString(data: data)
        }

        throw ParserError.invalidType(value: firstByte)
    }

    static func parseSequence(data: Data) throws -> [Node] {
        let scanner = Scanner(data: data)
        var nodes: [Node] = []
        while !scanner.isComplete {
            let node = try parseNode(scanner: scanner)
            nodes.append(node)
        }
        return nodes
    }
}
