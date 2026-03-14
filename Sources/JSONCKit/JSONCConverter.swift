/// Converts a JSONC byte buffer to valid JSON by replacing comments and trailing
/// commas with whitespace. The output is always the same length as the input so
/// that downstream parsers report correct byte offsets.
///
/// Handles:
/// - Single-line comments (`// ...`)
/// - Multi-line comments (`/* ... */`)
/// - Trailing commas before `}` or `]`
/// - String literals (skipped verbatim, including escaped quotes)
func convertJSONCToJSON(_ src: [UInt8]) -> [UInt8] {
    var dst: [UInt8] = []
    dst.reserveCapacity(src.count)
    var index = 0

    while index < src.count {
        if src[index] == UInt8(ascii: "/"), index < src.count - 1 {
            if src[index + 1] == UInt8(ascii: "/") {
                index = stripSingleLineComment(src: src, dst: &dst, from: index)
                continue
            }
            if src[index + 1] == UInt8(ascii: "*") {
                index = stripMultiLineComment(src: src, dst: &dst, from: index)
                continue
            }
        }

        dst.append(src[index])

        if src[index] == UInt8(ascii: "\"") {
            index = skipStringLiteral(src: src, dst: &dst, from: index)
        } else if src[index] == UInt8(ascii: "}") || src[index] == UInt8(ascii: "]") {
            removeTrailingComma(dst: &dst)
        }

        index += 1
    }

    assert(dst.count == src.count, "Output length (\(dst.count)) must equal input length (\(src.count))")
    return dst
}

// MARK: - Single-line comments

private func stripSingleLineComment(src: [UInt8], dst: inout [UInt8], from start: Int) -> Int {
    dst.append(UInt8(ascii: " "))
    dst.append(UInt8(ascii: " "))
    var index = start + 2
    while index < src.count {
        if src[index] == UInt8(ascii: "\n") {
            dst.append(UInt8(ascii: "\n"))
            break
        } else if src[index] == UInt8(ascii: "\t") || src[index] == UInt8(ascii: "\r") {
            dst.append(src[index])
        } else {
            dst.append(UInt8(ascii: " "))
        }
        index += 1
    }
    return index + 1
}

// MARK: - Multi-line comments

private func stripMultiLineComment(src: [UInt8], dst: inout [UInt8], from start: Int) -> Int {
    let commentStart = dst.count
    dst.append(UInt8(ascii: " "))
    dst.append(UInt8(ascii: " "))
    var index = start + 2
    var terminated = false

    while index < src.count - 1 {
        if src[index] == UInt8(ascii: "*"), src[index + 1] == UInt8(ascii: "/") {
            dst.append(UInt8(ascii: " "))
            dst.append(UInt8(ascii: " "))
            index += 2
            terminated = true
            break
        } else if isWhitespace(src[index]) {
            dst.append(src[index])
        } else {
            dst.append(UInt8(ascii: " "))
        }
        index += 1
    }

    if !terminated {
        if index < src.count {
            dst.append(UInt8(ascii: " "))
            index += 1
        }
        dst[commentStart] = UInt8(ascii: "/")
        dst[commentStart + 1] = UInt8(ascii: "*")
    }

    return index
}

// MARK: - String literals

private func skipStringLiteral(src: [UInt8], dst: inout [UInt8], from start: Int) -> Int {
    var index = start + 1
    while index < src.count {
        dst.append(src[index])
        if src[index] == UInt8(ascii: "\"") {
            var backtrackIndex = index - 1
            while backtrackIndex >= 0, src[backtrackIndex] == UInt8(ascii: "\\") {
                backtrackIndex -= 1
            }
            let backslashCount = index - 1 - backtrackIndex
            if backslashCount.isMultiple(of: 2) {
                break
            }
        }
        index += 1
    }
    return index
}

// MARK: - Trailing commas

private func removeTrailingComma(dst: inout [UInt8]) {
    var scanIndex = dst.count - 2
    while scanIndex >= 0 {
        if dst[scanIndex] > UInt8(ascii: " ") {
            if dst[scanIndex] == UInt8(ascii: ",") {
                dst[scanIndex] = UInt8(ascii: " ")
            }
            break
        }
        scanIndex -= 1
    }
}

// MARK: - Helpers

private func isWhitespace(_ byte: UInt8) -> Bool {
    byte == UInt8(ascii: "\n") || byte == UInt8(ascii: "\t") || byte == UInt8(ascii: "\r")
}
