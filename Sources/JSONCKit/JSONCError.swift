import Foundation

/// Errors that can occur during JSONC-to-JSON conversion.
public enum JSONCError: Error, Sendable {
    /// The input data could not be decoded using the specified string encoding.
    case invalidEncoding
}

extension JSONCError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidEncoding:
            "The input data could not be decoded with the specified encoding."
        }
    }
}
