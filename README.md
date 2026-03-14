# JSONCKit

A lightweight Swift package that converts [JSONC](https://jsonc.org) (JSON with Comments) to standard JSON.

- Zero dependencies
- Single-pass, length-preserving conversion
- Lenient — malformed input is passed through for downstream parsers to handle
- Swift 6 strict concurrency ready

## Features

- Strip single-line comments (`// ...`)
- Strip multi-line comments (`/* ... */`)
- Remove trailing commas in objects and arrays

## Installation

Add JSONCKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/steelbrain/JSONCKit.git", from: "1.0.0"),
]
```

Then add it as a dependency to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["JSONCKit"]
),
```

## Usage

### Convert a JSONC string to JSON

```swift
import JSONCKit

let jsonc = """
{
    // Database settings
    "host": "localhost",
    "port": 5432,
    /* Credentials */
    "user": "admin",
}
"""

let json = JSONC.convert(jsonc)
// json is now valid JSON with comments and trailing comma removed
```

### Convert JSONC Data to JSON Data

```swift
let jsoncData: Data = ...
let jsonData = try JSONC.convertToData(jsoncData)
```

### Decode a Decodable type directly

```swift
struct Config: Decodable {
    let host: String
    let port: Int
    let user: String
}

let config = try JSONC.decode(Config.self, from: jsoncData)
```

## API

| Method | Signature | Description |
|--------|-----------|-------------|
| `convert` | `(String) -> String` | Convert a JSONC string to JSON |
| `convertToData` | `(Data, encoding:) throws -> Data` | Convert JSONC data to JSON data |
| `decode` | `(T.Type, from:encoding:decoder:) throws -> T` | Decode a `Decodable` type from JSONC data |

## How it works

The converter makes a single pass over the input bytes, replacing comments and trailing commas with whitespace. The output is always the exact same byte length as the input, so downstream parsers report correct line and column positions for any errors they find.

## Attributions

See [ATTRIBUTIONS.md](ATTRIBUTIONS.md) for implementation and test suite references.

## License

MIT — see [LICENSE](LICENSE) for details.
