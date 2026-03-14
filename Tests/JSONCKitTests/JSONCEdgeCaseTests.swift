import Foundation
import Testing

@testable import JSONCKit

/// Edge case tests adopted from multiple JSONC implementations:
/// microsoft/node-jsonc-parser, otar/jsonc (PHP), n-takumasa/json-with-comments (Python),
/// dprint/jsonc-parser (Rust), massivefermion/jsonc (Elixir)
@Suite("Cross-Implementation Edge Cases")
struct JSONCEdgeCaseTests {
    // MARK: - Comment edge cases

    @Test("Empty block comment: /**/")
    func emptyBlockComment() {
        let input = #"{"a": /**/ 1}"#
        let output = JSONC.convert(input)
        #expect(output.contains("/*") == false)
        #expect(output.utf8.count == input.utf8.count)
        let data = Data(output.utf8)
        #expect(throws: Never.self) { _ = try JSONSerialization.jsonObject(with: data) }
    }

    @Test("Block comment with multiple asterisks: /***/")
    func blockCommentMultipleAsterisks() {
        let input = #"{"a": /***/ 1}"#
        let output = JSONC.convert(input)
        #expect(output.contains("/*") == false)
        #expect(output.utf8.count == input.utf8.count)
        let data = Data(output.utf8)
        #expect(throws: Never.self) { _ = try JSONSerialization.jsonObject(with: data) }
    }

    @Test("Triple slash treated as single-line comment")
    func tripleSlash() {
        let input = "/// triple slash\n{}"
        let output = JSONC.convert(input)
        #expect(output.contains("///") == false)
        #expect(output.contains("triple") == false)
        #expect(output.hasSuffix("\n{}"))
    }

    @Test("Single forward slash is not a comment")
    func singleSlash() {
        let input = "/"
        let output = JSONC.convert(input)
        #expect(output == "/")
    }

    @Test("Slash followed by non-comment character is not a comment")
    func slashNonComment() {
        let input = "/x"
        let output = JSONC.convert(input)
        #expect(output == "/x")
    }

    @Test("Comment between key and colon")
    func commentBetweenKeyAndColon() {
        let input = #"{"key" /* comment */ : "value"}"#
        let output = JSONC.convert(input)
        #expect(output.contains("comment") == false)
        #expect(output.utf8.count == input.utf8.count)
        let data = Data(output.utf8)
        #expect(throws: Never.self) { _ = try JSONSerialization.jsonObject(with: data) }
    }

    @Test("Comment between colon and value")
    func commentBetweenColonAndValue() {
        let input = #"{"key": /* comment */ "value"}"#
        let output = JSONC.convert(input)
        #expect(output.contains("comment") == false)
        let data = Data(output.utf8)
        #expect(throws: Never.self) { _ = try JSONSerialization.jsonObject(with: data) }
    }

    @Test("Comment-only input with no JSON value")
    func commentOnlyInput() {
        let input = "// just a comment"
        let output = JSONC.convert(input)
        #expect(output.contains("//") == false)
        #expect(output.contains("comment") == false)
        #expect(output.utf8.count == input.utf8.count)
    }

    @Test("Block comment-only input")
    func blockCommentOnlyInput() {
        let input = "/* just a block comment */"
        let output = JSONC.convert(input)
        #expect(output.contains("/*") == false)
        #expect(output.utf8.count == input.utf8.count)
    }

    @Test("Nested comment markers: only first */ closes the comment")
    func nestedCommentMarkers() {
        let input = #"/* a /* b */ {"key": 1}"#
        let output = JSONC.convert(input)
        #expect(output.contains("/*") == false)
        #expect(output.utf8.count == input.utf8.count)
        let data = Data(output.utf8)
        #expect(throws: Never.self) { _ = try JSONSerialization.jsonObject(with: data) }
    }

    @Test("Multiple block comments on same line")
    func multipleBlockCommentsSameLine() {
        let input = #"/* a */ {"key": /* b */ 1} /* c */"#
        let output = JSONC.convert(input)
        #expect(output.contains("/*") == false)
        #expect(output.contains("*/") == false)
        #expect(output.utf8.count == input.utf8.count)
    }

    // MARK: - Line ending handling

    @Test("CR alone does not terminate single-line comment")
    func crAloneDoesNotTerminateComment() {
        let input = "// comment\r{}"
        let output = JSONC.convert(input)
        #expect(output.contains("{") == false)
        #expect(output.utf8.count == input.utf8.count)
    }

    @Test("CRLF terminates single-line comment correctly")
    func crlfTerminatesSingleLineComment() {
        let input = "// comment\r\n{}"
        let output = JSONC.convert(input)
        #expect(output.hasSuffix("\r\n{}"))
        #expect(output.utf8.count == input.utf8.count)
    }

    @Test("Multiple CRLF lines with comments")
    func multipleCrlfComments() {
        let input = "// a\r\n// b\r\n{}"
        let output = JSONC.convert(input)
        #expect(output.hasSuffix("\r\n{}"))
        #expect(output.contains("//") == false)
        #expect(output.utf8.count == input.utf8.count)
    }

    // MARK: - Unicode in comments

    @Test("Multi-byte UTF-8 characters inside block comments")
    func unicodeInBlockComment() {
        let input = #"/* 你好 🚀 */ {"key": 1}"#
        let output = JSONC.convert(input)
        #expect(output.contains("你好") == false)
        #expect(output.contains("🚀") == false)
        #expect(output.utf8.count == input.utf8.count)
        let data = Data(output.utf8)
        #expect(throws: Never.self) { _ = try JSONSerialization.jsonObject(with: data) }
    }

    @Test("Multi-byte UTF-8 characters inside single-line comments")
    func unicodeInLineComment() {
        let input = "// 日本語コメント\n{}"
        let output = JSONC.convert(input)
        #expect(output.contains("日本語") == false)
        #expect(output.hasSuffix("\n{}"))
        #expect(output.utf8.count == input.utf8.count)
    }

    // MARK: - String edge cases

    @Test("Comment syntax as object keys are preserved")
    func commentSyntaxAsKeys() {
        let input = #"{"//": "v1", "/*": "v2"}"#
        let output = JSONC.convert(input)
        #expect(output == input)
    }

    @Test("Escaped forward slash in string")
    func escapedForwardSlashInString() {
        let input = #"{"url": "https:\/\/example.com"}"#
        let output = JSONC.convert(input)
        #expect(output == input)
    }

    @Test("Empty string values and keys")
    func emptyStringValuesAndKeys() {
        let input = #"{"": "", "a": ""}"#
        let output = JSONC.convert(input)
        #expect(output == input)
    }

    @Test("String with all JSON escape sequences")
    func allEscapeSequences() {
        let input = #"{"k": "a\nb\tc\rd\\e\"f\/g"}"#
        let output = JSONC.convert(input)
        #expect(output == input)
    }

    @Test("String with unicode escape sequence")
    func unicodeEscapeInString() {
        let input = #"{"k": "\u0048\u0065\u006C\u006C\u006F"}"#
        let output = JSONC.convert(input)
        #expect(output == input)
    }

    // MARK: - Trailing comma edge cases

    @Test("Nested trailing commas in objects and arrays")
    func nestedTrailingCommas() {
        let input = #"{"a": {"b": [1, 2,], "c": 3,}, "d": [{"e": 4,},],}"#
        let output = JSONC.convert(input)
        #expect(output.utf8.count == input.utf8.count)
        let data = Data(output.utf8)
        #expect(throws: Never.self) { _ = try JSONSerialization.jsonObject(with: data) }
    }

    @Test("Trailing comma followed by comment before closing bracket")
    func trailingCommaWithComment() {
        let input = "[1, 2, // comment\n]"
        let output = JSONC.convert(input)
        #expect(output.utf8.count == input.utf8.count)
        let data = Data(output.utf8)
        #expect(throws: Never.self) { _ = try JSONSerialization.jsonObject(with: data) }
    }

    @Test("Trailing comma with block comment before closing brace")
    func trailingCommaWithBlockComment() {
        let input = #"{"a": 1, /* comment */}"#
        let output = JSONC.convert(input)
        #expect(output.utf8.count == input.utf8.count)
        let data = Data(output.utf8)
        #expect(throws: Never.self) { _ = try JSONSerialization.jsonObject(with: data) }
    }
}
