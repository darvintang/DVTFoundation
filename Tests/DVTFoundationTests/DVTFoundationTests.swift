import XCTest
@testable import DVTFoundation

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
        XCTAssertEqual(str.dvt[-1, length: 10], "0123456789")

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
        XCTAssertEqual(str.dvt[-1, to: 9], "0123456789")

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
        XCTAssertEqual("18112341234".dvt.replacing(3, to: 6, with: "****"), "181****1234")
        XCTAssertEqual(str.dvt.replacing(0, to: 1, with: "**"), "**23456789")
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
        print(System.machine)
        var list = ["12"]
        XCTAssertEqual(list.dvt_remove("12"), "12")
        XCTAssertTrue(list.isEmpty)
    }

    func testCompareVersion() {
        XCTAssertTrue("12.34.56".dvt.compare("12.3.56", separator: ".") == .greater)
        XCTAssertTrue("12.2.56".dvt.compare("12.3.56", separator: ".") == .less)
        XCTAssertTrue("12.34.56".dvt.compare("12.34.56", separator: ".") == .equal)
        XCTAssertTrue("12.34.56".dvt.compare("12.34", separator: ".") == .greater)
        XCTAssertTrue("12.34a.56".dvt.compare("12.34a", separator: ".") == .greater)
        XCTAssertTrue("12.34a.56".dvt.compare("12.34a.1", separator: ".") == .greater)
        XCTAssertTrue("12.34b.56".dvt.compare("12.34a.70", separator: ".") == .greater)
        XCTAssertTrue("12.34a.56".dvt.compare("12.34a.70", separator: ".") == .less)
        XCTAssertTrue("1.34a.56".dvt.compare("12.34a.1", separator: ".") == .less)
    }
}
