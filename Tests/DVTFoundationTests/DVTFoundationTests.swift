@testable import DVTFoundation
import XCTest

final class DVTFoundationTests: XCTestCase {
    func testString() throws {
        let str = "0123456789"

        XCTAssertEqual(str.dvt.insert("abc", at: -3), "abc0123456789")
        XCTAssertEqual(str.dvt.insert("abc", at: 3), "012abc3456789")
        XCTAssertEqual(str.dvt.insert("abc", at: 13), "0123456789abc")

        XCTAssertEqual(str.dvt[-1], "")
        XCTAssertEqual(str.dvt[1], "1")
        XCTAssertEqual(str.dvt[100], "")

        XCTAssertEqual(str.dvt[-1, length: -10], "")
        XCTAssertEqual(str.dvt[-1, length: 0], "")
        XCTAssertEqual(str.dvt[-1, length: 3], "012")
        XCTAssertEqual(str.dvt[-1, length: 12], "0123456789")

        XCTAssertEqual(str.dvt[1, length: -10], "")
        XCTAssertEqual(str.dvt[1, length: 0], "")
        XCTAssertEqual(str.dvt[1, length: 3], "123")
        XCTAssertEqual(str.dvt[1, length: 12], "123456789")

        XCTAssertEqual(str.dvt[10, length: -10], "")
        XCTAssertEqual(str.dvt[10, length: 0], "")
        XCTAssertEqual(str.dvt[10, length: 3], "")
        XCTAssertEqual(str.dvt[10, length: 12], "")

        XCTAssertEqual(str.dvt[-1, to: -2], "")
        XCTAssertEqual(str.dvt[-1, to: 0], "0")
        XCTAssertEqual(str.dvt[-1, to: 1], "01")
        XCTAssertEqual(str.dvt[-1, to: 2], "012")
        XCTAssertEqual(str.dvt[-1, to: 12], "0123456789")

        XCTAssertEqual(str.dvt[1, to: -2], "")
        XCTAssertEqual(str.dvt[1, to: 0], "")
        XCTAssertEqual(str.dvt[1, to: 1], "1")
        XCTAssertEqual(str.dvt[1, to: 2], "12")
        XCTAssertEqual(str.dvt[1, to: 12], "123456789")

        XCTAssertEqual(str.dvt[98, to: -2], "")
        XCTAssertEqual(str.dvt[8, to: 0], "")
        XCTAssertEqual(str.dvt[8, to: 1], "")
        XCTAssertEqual(str.dvt[8, to: 9], "89")
        XCTAssertEqual(str.dvt[8, to: 12], "89")

        XCTAssertEqual(str.dvt[9, to: -2], "")
        XCTAssertEqual(str.dvt[9, to: 0], "")
        XCTAssertEqual(str.dvt[9, to: 1], "")
        XCTAssertEqual(str.dvt[9, to: 9], "9")
        XCTAssertEqual(str.dvt[9, to: 12], "9")

        XCTAssertEqual(str.dvt[10, to: -2], "")
        XCTAssertEqual(str.dvt[10, to: 0], "")
        XCTAssertEqual(str.dvt[10, to: 1], "")
        XCTAssertEqual(str.dvt[10, to: 10], "")
        XCTAssertEqual(str.dvt[10, to: 12], "")
        XCTAssertEqual("18112341234".dvt.replace(3, to: 6, with: "****"), "181****1234")
        XCTAssertEqual(str.dvt.replace(0, to: 1, with: "**"), "**23456789")
        XCTAssertEqual("123456789".dvt[2, to: "4"], "3")
    }

    func testRegularValidate() {
        let string = "18112341234"
        if string.dvt.regularValidate("^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$") {
            print(1)
        } else {
            print(2)
        }
    }

    func testDate() throws {
        let format = "yyyy-MM-dd HH:mm:ss"
        let string = "2021-01-01 16:30:20"
        let date = string.dvt.date(of: format)

        print(date?.dvt.string(of: format) as Any)
        XCTAssertEqual(date?.dvt.string(of: format), string)
        XCTAssertEqual(string.dvt.date(of: format), date)
    }

    func testMD5() throws {
        XCTAssertEqual("1234567890".dvt.md5, "E807F1FCF82D132F9BB018CA6738A19F")
        XCTAssertEqual("".dvt.md5, "D41D8CD98F00B204E9800998ECF8427E")
    }

    func testJSON() {
        let dict = """
        {"key":"value"}
        """.dvtJson.json
        print([["key": "value", "key1": 123], ["key": "value", "key1": 123]].dvtJson.json ?? "")
        XCTAssertEqual(dict as? [String: String], ["key": "value"])
    }

    func testPinYin() {
        XCTAssertEqual("你好".dvt.pinyin, "ni hao")
    }

    func testArray() {
        var list = ["12"]
        XCTAssertEqual(list.dvt_remove("12"), "12")
        XCTAssertTrue(list.isEmpty)
    }
}
