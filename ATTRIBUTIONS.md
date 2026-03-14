# Attributions

JSONCKit's implementation and test suite were informed by several open-source
JSONC libraries. All referenced projects use permissive (MIT) licenses.

## Implementation Reference

- **[tidwall/jsonc](https://github.com/tidwall/jsonc)** (Go, MIT)
  Copyright (c) 2021 Josh Baker.
  The single-pass, length-preserving conversion algorithm in JSONCKit is based
  on the approach used in this library.

## Test Suite References

Test cases were adopted and adapted from the following projects:

- **[tidwall/jsonc](https://github.com/tidwall/jsonc)** (Go, MIT)
  Copyright (c) 2021 Josh Baker.
  Exact byte-for-byte output tests and the Issue #3 regression tests.

- **[microsoft/node-jsonc-parser](https://github.com/microsoft/node-jsonc-parser)** (TypeScript, MIT)
  Copyright (c) Microsoft Corporation.
  Test ideas for comments in all positions around object properties and array
  elements, comment-only input, and comments between key/colon/value.

- **[otar/jsonc](https://github.com/otar/jsonc)** (PHP, MIT)
  Copyright (c) Otar Chekurishvili.
  Edge case ideas including empty block comments, multiple asterisks in
  comments, triple slash, single slash, comment syntax as object keys, escaped
  forward slashes, unicode escape sequences, nested trailing commas, and
  realistic config file scenarios.

- **[n-takumasa/json-with-comments](https://github.com/n-takumasa/json-with-comments)** (Python, MIT)
  Copyright (c) 2022 n-takumasa.
  Test ideas for CR and CRLF line ending handling in single-line comments.

- **[dprint/jsonc-parser](https://github.com/dprint/jsonc-parser)** (Rust, MIT)
  Copyright (c) 2020 David Sherret.
  Test ideas for multi-byte UTF-8 characters inside comments and string
  escape sequence handling.
