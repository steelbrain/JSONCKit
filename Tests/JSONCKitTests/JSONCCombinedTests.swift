import Foundation
import Testing

@testable import JSONCKit

/// Complex combined scenario tests adopted from multiple JSONC implementations.
@Suite("Complex Combined Scenarios")
struct JSONCCombinedTests {
    @Test("Deeply nested structure with comments and trailing commas")
    func deeplyNestedCombined() {
        let input = """
            {
                "a": {
                    "b": [
                        1, // one
                        2, /* two */
                        3,
                    ],
                },
            }
            """
        let output = JSONC.convert(input)
        #expect(output.utf8.count == input.utf8.count)
        let data = Data(output.utf8)
        #expect(throws: Never.self) { _ = try JSONSerialization.jsonObject(with: data) }
    }

    @Test("Mixed comment styles throughout a document")
    func mixedCommentStyles() {
        let input = """
            {
                // line comment
                "a": 1,
                /* block
                   comment */
                "b": 2, // inline
                "c": /* inline block */ 3,
            }
            """
        let output = JSONC.convert(input)
        #expect(output.utf8.count == input.utf8.count)
        #expect(output.contains("//") == false)
        #expect(output.contains("/*") == false)
        let data = Data(output.utf8)
        #expect(throws: Never.self) { _ = try JSONSerialization.jsonObject(with: data) }
    }

    @Test("Realistic tsconfig.json with comments")
    func realisticTsconfig() {
        let input = """
            {
                // Compiler options
                "compilerOptions": {
                    "target": "es2020",
                    "module": "commonjs",
                    "strict": true, // Enable strict mode
                    "outDir": "./dist",
                },
                /* Files to include */
                "include": [
                    "src/**/*",
                ],
                // Files to exclude
                "exclude": [
                    "node_modules",
                    "dist",
                ],
            }
            """
        let output = JSONC.convert(input)
        #expect(output.utf8.count == input.utf8.count)
        let data = Data(output.utf8)
        #expect(throws: Never.self) { _ = try JSONSerialization.jsonObject(with: data) }
    }

    @Test("Comments in all positions around object properties")
    func commentsInAllPositions() {
        let input = [
            #"/* 1 */ { /* 2 */ "a" /* 3 */ : /* 4 */ 1 /* 5 */"#,
            #" , /* 6 */ "b" /* 7 */ : /* 8 */ 2 /* 9 */ }"#,
        ].joined()
        let output = JSONC.convert(input)
        #expect(output.utf8.count == input.utf8.count)
        #expect(output.contains("/*") == false)
        let data = Data(output.utf8)
        #expect(throws: Never.self) { _ = try JSONSerialization.jsonObject(with: data) }
    }

    @Test("Comments in all positions around array elements")
    func commentsInAllArrayPositions() {
        let input = "/* 1 */ [ /* 2 */ 1 /* 3 */ , /* 4 */ 2 /* 5 */ , /* 6 */ 3 /* 7 */ ]"
        let output = JSONC.convert(input)
        #expect(output.utf8.count == input.utf8.count)
        #expect(output.contains("/*") == false)
        let data = Data(output.utf8)
        #expect(throws: Never.self) { _ = try JSONSerialization.jsonObject(with: data) }
    }
}
