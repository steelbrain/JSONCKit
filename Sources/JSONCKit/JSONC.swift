import Foundation

/// A utility for converting JSONC (JSON with Comments) to standard JSON.
///
/// JSONC extends JSON with support for:
/// - Single-line comments (`// ...`)
/// - Multi-line comments (`/* ... */`)
/// - Trailing commas in objects and arrays
///
/// The converter is lenient — malformed input (e.g. unterminated comments or strings)
/// is passed through as-is for downstream parsers to handle.
///
/// ## Usage
///
/// Convert a JSONC string to JSON:
/// ```swift
/// let json = JSONC.convert(jsoncString)
/// ```
///
/// Convert JSONC data to JSON data:
/// ```swift
/// let jsonData = try JSONC.convertToData(jsoncData)
/// ```
///
/// Decode a `Decodable` type directly from JSONC data:
/// ```swift
/// let config = try JSONC.decode(Config.self, from: jsoncData)
/// ```
public enum JSONC {
    /// Converts a JSONC string to a valid JSON string.
    ///
    /// Comments are replaced with whitespace to preserve byte offsets, so downstream
    /// parsers report correct positions for any errors they find.
    ///
    /// - Parameter jsonc: A string containing JSONC content.
    /// - Returns: A string containing valid JSON with comments and trailing commas removed.
    public static func convert(_ jsonc: String) -> String {
        let src = Array(jsonc.utf8)
        let dst = convertJSONCToJSON(src)
        return String(bytes: dst, encoding: .utf8) ?? jsonc
    }

    /// Converts JSONC data to valid JSON data.
    ///
    /// - Parameters:
    ///   - data: Data containing JSONC content.
    ///   - encoding: The string encoding to use. Defaults to `.utf8`.
    /// - Returns: Data containing valid JSON.
    /// - Throws: ``JSONCError/invalidEncoding`` if the input cannot be decoded
    ///   with the specified encoding.
    public static func convertToData(_ data: Data, encoding: String.Encoding = .utf8) throws -> Data {
        guard let jsonc = String(data: data, encoding: encoding) else {
            throw JSONCError.invalidEncoding
        }
        let json = convert(jsonc)
        guard let result = json.data(using: encoding) else {
            throw JSONCError.invalidEncoding
        }
        return result
    }

    /// Decodes a `Decodable` type from JSONC data.
    ///
    /// This is a convenience method that converts JSONC to JSON and then decodes using `JSONDecoder`.
    ///
    /// - Parameters:
    ///   - type: The type to decode.
    ///   - data: Data containing JSONC content.
    ///   - encoding: The string encoding to use. Defaults to `.utf8`.
    ///   - decoder: The `JSONDecoder` to use. Defaults to a new instance.
    /// - Returns: A decoded instance of the specified type.
    /// - Throws: ``JSONCError/invalidEncoding`` if the encoding fails,
    ///   or a `DecodingError` if JSON decoding fails.
    public static func decode<T: Decodable>(
        _ type: T.Type,
        from data: Data,
        encoding: String.Encoding = .utf8,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        let jsonData = try convertToData(data, encoding: encoding)
        return try decoder.decode(type, from: jsonData)
    }
}
