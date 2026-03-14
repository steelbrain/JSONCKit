import Foundation
import Testing

@testable import JSONCKit

@Suite("Upstream & Invariant Tests")
struct JSONCUpstreamTests {
    // MARK: - Exact output tests (ported from tidwall/jsonc)

    @Test("Upstream: complex combined conversion with exact output")
    func upstreamCombined() {
        let input = [
            "",
            "  {  //\thello",
            #"    "c": 3,"b":3, // jello"#,
            "    /* SOME",
            "       LIKE",
            "       IT",
            "       HAUT */",
            #"    "d\\\"\"e": [ 1, /* 2 */ 3, 4, ],"#,
            "  }",
        ].joined(separator: "\n")

        let expected = [
            "",
            "  {    \t     ",
            #"    "c": 3,"b":3,"# + String(repeating: " ", count: 9),
            String(repeating: " ", count: 11),
            String(repeating: " ", count: 11),
            String(repeating: " ", count: 9),
            String(repeating: " ", count: 14),
            #"    "d\\\"\"e": [ 1,"# + String(repeating: " ", count: 9) + "3, 4  ] ",
            "  }",
        ].joined(separator: "\n")

        #expect(input.count == expected.count)
        let output = JSONC.convert(input)
        #expect(output == expected)
    }

    @Test("Upstream: unterminated comment after terminated comment")
    func upstreamIssue3Unterminated() {
        let input = [
            #"{"a":1}/* unclosed"#,
            "  asdasdf  asdfsadf */ /* asdf",
        ].joined(separator: "\n")

        let expected = [
            #"{"a":1}"# + String(repeating: " ", count: 11),
            String(repeating: " ", count: 23) + "/*" + String(repeating: " ", count: 5),
        ].joined(separator: "\n")

        #expect(input.count == expected.count)
        let output = JSONC.convert(input)
        #expect(output == expected)
    }

    @Test("Upstream: terminated comment followed by terminated comment")
    func upstreamIssue3Terminated() {
        let input = [
            #"{"a":1}/* unclosed"#,
            "  asdasdf  asdfsadf */ /* asdf*/",
        ].joined(separator: "\n")

        let expected = [
            #"{"a":1}"# + String(repeating: " ", count: 11),
            String(repeating: " ", count: 32),
        ].joined(separator: "\n")

        #expect(input.count == expected.count)
        let output = JSONC.convert(input)
        #expect(output == expected)
    }

    // MARK: - Length invariant (edge cases)

    @Test("Length invariant: comment boundary tokens")
    func lengthInvariantCommentBoundaries() {
        let inputs = [
            "", "/", "//", "/*", "*/", "/**", "/*/", "/**/",
            #"""#, #""""#, #""\""#,
            "//\n", "// \n", "/* */",
            "//no newline at end", "/* no close", "/* almost */close",
        ]
        for input in inputs {
            let output = JSONC.convert(input)
            #expect(output.utf8.count == input.utf8.count, "Mismatch: \(input.debugDescription)")
        }
    }

    @Test("Length invariant: single characters")
    func lengthInvariantSingleChars() {
        let inputs = ["{", "}", "[", "]", ",", " ", "\n", "\t"]
        for input in inputs {
            let output = JSONC.convert(input)
            #expect(output.utf8.count == input.utf8.count, "Mismatch: \(input.debugDescription)")
        }
    }

    @Test("Length invariant: strings with tricky content")
    func lengthInvariantStrings() {
        let inputs = [
            #"{"k": "v"}"#,
            #"{"k": "\\"}"#,
            #"{"k": "\""}"#,
            #"{"k": "\\\""}"#,
            #"{"k": "//not a comment"}"#,
            #"{"k": "/* not a comment */"}"#,
        ]
        for input in inputs {
            let output = JSONC.convert(input)
            #expect(output.utf8.count == input.utf8.count, "Mismatch: \(input.debugDescription)")
        }
    }

    @Test("Length invariant: trailing commas")
    func lengthInvariantTrailingCommas() {
        let inputs = [
            "[,]", "[1,]", "[1, ]", "[1 ,]",
            #"{"a":1,}"#, #"{"a":1, }"#, "[1,[2,],]",
            #"{"a":{"b":1,},}"#, "[[1,],]",
        ]
        for input in inputs {
            let output = JSONC.convert(input)
            #expect(output.utf8.count == input.utf8.count, "Mismatch: \(input.debugDescription)")
        }
    }

    @Test("Length invariant: mixed comments and commas")
    func lengthInvariantMixed() {
        let inputs = [
            "[1,/* x */]",
            "[1, // x\n]",
            #"{"a":1,// comment\n}"#,
            "/* a *//* b *//* c */",
            "// a\n// b\n// c\n",
            "   ", "\n\n\n", "\t\t\t",
        ]
        for input in inputs {
            let output = JSONC.convert(input)
            #expect(output.utf8.count == input.utf8.count, "Mismatch: \(input.debugDescription)")
        }
    }
}
