import Foundation
import Testing

@testable import JSONCKit

@Suite("JSONC Conversion")
struct JSONCTests {
    // MARK: - Pass-through

    @Test("Passes through plain JSON unchanged")
    func plainJSON() {
        let input = #"{"key": "value", "number": 42}"#
        #expect(JSONC.convert(input) == input)
    }

    @Test("Empty string returns empty string")
    func emptyInput() {
        #expect(JSONC.convert("").isEmpty)
    }

    // MARK: - Single-line comments

    @Test("Strips single-line comment on its own line")
    func singleLineComment() {
        let input = """
            {
            // this is a comment
            "key": "value"
            }
            """
        let output = JSONC.convert(input)
        #expect(output.contains("//") == false)
        #expect(output.contains("this is a comment") == false)
        #expect(output.count == input.count)
    }

    @Test("Strips single-line comment after a value")
    func singleLineCommentAfterValue() {
        let input = #"{"key": 1} // trailing"#
        let output = JSONC.convert(input)
        #expect(output.contains("//") == false)
        #expect(output.contains("trailing") == false)
        #expect(output.count == input.count)
    }

    @Test("Preserves newlines in single-line comments")
    func singleLineCommentPreservesNewline() {
        let input = "// comment\n{}"
        let output = JSONC.convert(input)
        #expect(output.hasSuffix("\n{}"))
    }

    // MARK: - Multi-line comments

    @Test("Strips multi-line comment")
    func multiLineComment() {
        let input = #"{"key": /* comment */ "value"}"#
        let output = JSONC.convert(input)
        #expect(output.contains("/*") == false)
        #expect(output.contains("*/") == false)
        #expect(output.contains("comment") == false)
        #expect(output.count == input.count)
    }

    @Test("Preserves newlines within multi-line comments")
    func multiLineCommentWithNewlines() {
        let input = "{\n/* line1\nline2\nline3 */\n\"key\": 1\n}"
        let output = JSONC.convert(input)
        let inputNewlines = input.filter { $0 == "\n" }.count
        let outputNewlines = output.filter { $0 == "\n" }.count
        #expect(inputNewlines == outputNewlines)
        #expect(output.count == input.count)
    }

    @Test("Handles unterminated multi-line comment leniently")
    func unterminatedMultiLineComment() {
        let input = "/* unterminated"
        let output = JSONC.convert(input)
        #expect(output.contains("/*"))
        #expect(output.count == input.count)
    }

    @Test("Handles adjacent comments")
    func adjacentComments() {
        let input = #"/* a *//* b */{"key": 1}"#
        let output = JSONC.convert(input)
        #expect(output.contains("/*") == false)
        #expect(output.count == input.count)
    }

    // MARK: - String literals

    @Test("Does not strip comment syntax inside strings")
    func commentInsideString() {
        let input = #"{"key": "http://example.com"}"#
        let output = JSONC.convert(input)
        #expect(output == input)
    }

    @Test("Does not strip block comment syntax inside strings")
    func blockCommentInsideString() {
        let input = #"{"key": "/* not a comment */"}"#
        let output = JSONC.convert(input)
        #expect(output == input)
    }

    @Test("Handles escaped quotes in strings")
    func escapedQuotesInString() {
        let input = #"{"key": "value with \" escaped quote"}"#
        let output = JSONC.convert(input)
        #expect(output == input)
    }

    @Test("Handles multiple escaped backslashes before quote")
    func multipleBackslashesBeforeQuote() {
        let input = #"{"key": "ends with backslash\\\\"}"#
        let output = JSONC.convert(input)
        #expect(output == input)
    }

    // MARK: - Trailing commas

    @Test("Removes trailing comma in object")
    func trailingCommaObject() {
        let input = #"{"a": 1, "b": 2, }"#
        let output = JSONC.convert(input)
        #expect(output.count == input.count)
        let data = Data(output.utf8)
        #expect(throws: Never.self) {
            _ = try JSONSerialization.jsonObject(with: data)
        }
    }

    @Test("Removes trailing comma in array")
    func trailingCommaArray() {
        let input = "[1, 2, 3, ]"
        let output = JSONC.convert(input)
        #expect(output.count == input.count)
        let data = Data(output.utf8)
        #expect(throws: Never.self) {
            _ = try JSONSerialization.jsonObject(with: data)
        }
    }

    @Test("Removes trailing comma with whitespace before bracket")
    func trailingCommaWithWhitespace() {
        let input = """
            {
                "a": 1,
            }
            """
        let output = JSONC.convert(input)
        #expect(output.count == input.count)
        let data = Data(output.utf8)
        #expect(throws: Never.self) {
            _ = try JSONSerialization.jsonObject(with: data)
        }
    }

    // MARK: - Combined

    @Test("Handles comments and trailing commas together")
    func commentsAndTrailingCommas() {
        let input = """
            {
                // name of the app
                "name": "MyApp",
                /* version info */
                "version": "1.0",
            }
            """
        let output = JSONC.convert(input)
        #expect(output.count == input.count)
        let data = Data(output.utf8)
        #expect(throws: Never.self) {
            _ = try JSONSerialization.jsonObject(with: data)
        }
    }

    // MARK: - Output length preservation

    @Test("Output is always the same byte length as input")
    func outputLengthPreserved() {
        let inputs = [
            #"{"key": "value"}"#,
            "// comment\n{}",
            "/* block */{}",
            #"{"a": 1, }"#,
            #"{"url": "http://example.com"}"#,
            "/* unterminated",
        ]
        for input in inputs {
            let output = JSONC.convert(input)
            #expect(
                output.utf8.count == input.utf8.count,
                "Length mismatch for input: \(input)"
            )
        }
    }

    // MARK: - Data API

    @Test("convertToData works with valid UTF-8")
    func convertToData() throws {
        let input = "// comment\n{}"
        let data = Data(input.utf8)
        let result = try JSONC.convertToData(data)
        let output = String(data: result, encoding: .utf8)
        #expect(output?.contains("//") == false)
    }

    @Test("convertToData throws for invalid encoding")
    func convertToDataInvalidEncoding() {
        let data = Data([0xFF, 0xFE])
        #expect(throws: JSONCError.self) {
            _ = try JSONC.convertToData(data)
        }
    }

    // MARK: - Decode API

    @Test("decode parses JSONC into a Decodable type")
    func decodable() throws {
        struct Config: Decodable {
            let name: String
            let version: Int
        }

        let input = """
            {
                // app config
                "name": "TestApp",
                "version": 2,
            }
            """
        let data = Data(input.utf8)
        let config = try JSONC.decode(Config.self, from: data)
        #expect(config.name == "TestApp")
        #expect(config.version == 2)
    }
}
