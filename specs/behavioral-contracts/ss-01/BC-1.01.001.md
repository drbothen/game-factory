---
document_type: behavioral-contract
level: L3
version: "1.1"
status: draft
producer: product-owner
timestamp: 2026-06-07T00:00:00Z
phase: 1a
inputs:
  - .factory/specs/domain-spec/capabilities.md
  - .factory/planning/design/protocol-schema.md
  - .factory/planning/design/engine-adapter-protocol.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
traces_to: domain-spec/L2-INDEX.md
origin: greenfield
subsystem: SS-01
capability: CAP-001
priority: P0
lifecycle_status: active
introduced: v0.1.0
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# BC-1.01.001: JSON-RPC 2.0 stdio Transport with LSP-Style Content-Length Framing

## Description

Every message exchanged between the factory core (client) and an engine adapter
(server) is a JSON-RPC 2.0 object framed with an HTTP-style `Content-Length`
header over stdio, exactly as Language Server Protocol specifies. This ensures
any-language adapters can be implemented without an FFI boundary. The core drives
all requests; the adapter never initiates requests (only notifications and responses).

## Preconditions

1. The adapter process has been spawned by the factory core as a subprocess.
2. The adapter's stdin and stdout file descriptors are connected to the core's
   output and input pipes respectively.
3. No other process reads from or writes to the adapter's stdio streams.

## Postconditions

1. Every message sent from core to adapter is preceded by a header of exactly the
   form `Content-Length: <N>\r\n\r\n` where `<N>` is the byte length of the
   JSON payload encoded as UTF-8.
2. Every message sent from adapter to core is preceded by a `Content-Length` header
   of the same form.
3. The JSON body is a valid JSON-RPC 2.0 object: for requests, fields `jsonrpc`,
   `id`, `method`, `params`; for notifications, fields `jsonrpc`, `method`, `params`
   (no `id`); for responses, fields `jsonrpc`, `id`, and either `result` or `error`.
4. The `jsonrpc` field is always the string `"2.0"`.
5. The adapter never sends a JSON-RPC request to the core (only responses and
   notifications); all requests originate from the core.

## Invariants

1. The `Content-Length` value equals the exact byte count of the UTF-8-encoded JSON
   body that follows; a mismatch causes a ParseError (`-32700`).
2. Messages are never interleaved: each message is fully delivered before the next begins.
3. The core and adapter agree on byte encoding: UTF-8 throughout.

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | JSON body contains multi-byte UTF-8 characters (e.g., non-ASCII paths) | Content-Length reflects byte count, not character count; message parses correctly |
| EC-002 | Adapter receives a message with Content-Length < actual body length | Adapter reads Content-Length bytes; remaining bytes are treated as start of next message; if the fragment is not a valid JSON-RPC object a ParseError response is returned |
| EC-003 | Adapter receives a message with Content-Length > actual body length | Adapter blocks waiting for remaining bytes; if stream closes before bytes arrive, adapter emits a ParseError and closes the connection |
| EC-004 | Core sends a notification (no `id` field) | Adapter processes it and sends no response (notifications are fire-and-forget per JSON-RPC 2.0 spec) |
| EC-005 | Adapter's stderr | Adapter may use stderr for diagnostic output; core does not parse stderr as JSON-RPC |

## Canonical Test Vectors

| Input | Expected Output | Category |
|-------|----------------|----------|
| `Content-Length: 58\r\n\r\n{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}` | Adapter parses the message and processes `initialize` | happy-path |
| `Content-Length: 12\r\n\r\n{"jsonrpc":"2.0","method":"initialized","params":{}}` | Adapter processes notification; no response sent | happy-path |
| `Content-Length: 5\r\n\r\n{"jsonrpc":"2.0","id":1,"method":"build","params":{}}` | Content-Length mismatch: adapter returns `{"jsonrpc":"2.0","id":null,"error":{"code":-32700,"message":"Parse error"}}` | error |
| Message body with `"path": "/tmp/データ"` (multi-byte UTF-8) | Content-Length = byte count = len in bytes of the UTF-8 string; parsed correctly | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-TBD-001 | For all valid UTF-8 payloads, Content-Length equals the byte count | proptest: generate random JSON objects, encode, assert header matches |
| VP-TBD-002 | No message with a valid Content-Length/body pair ever results in ParseError | proptest over well-formed inputs |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 |
| Capability Anchor Justification | CAP-001 ("Engine-Agnostic Game Build and Test") per capabilities.md §CAP-001 — this BC defines the wire-format invariant that makes all adapter communication engine-agnostic |
| L2 Domain Invariants | DI-001 (factory core never names engine — framing is engine-neutral JSON-RPC) |
| Architecture Module | Engine Adapter Protocol Layer 3 (filled by architect) |
| Stories | S-TBD (filled by story-writer) |

## Related BCs

- BC-1.02.001 — depends on (lifecycle `initialize` uses this framing)
- BC-1.13.001 — depends on (CapabilityUnsupported error is delivered via this framing)

## Architecture Anchors

- `planning/design/protocol-schema.md#0-transport--framing` — canonical framing spec
- `planning/design/engine-adapter-protocol.md#design-pattern--precedents` — LSP precedent

## Story Anchor

S-TBD — Engine Adapter Protocol transport layer

## VP Anchors

- VP-TBD-001 — Content-Length byte-count correctness
