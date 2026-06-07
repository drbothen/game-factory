# game-factory

An **engine-agnostic** multi-agent factory for game development — a sibling of
[vsdd-factory](../vsdd-factory) that reuses its orchestration spine but replaces
the verification/quality model with one suited to games (deterministic-sim
contracts + playtest-validated design intent).

> **Status:** Spec-input phase. game-factory is a **product built BY
> [vsdd-factory](../vsdd-factory)** following the full VSDD protocol. This repo is the
> **VSDD input package** — the canonical entry artifact is the product brief at
> [`.factory/specs/product-brief.md`](.factory/specs/product-brief.md); `docs/research/`
> is the planning research that backs it; `docs/design/` + `docs/decisions/` are
> Phase-1 seed inputs. vsdd-factory's pipeline produces the formal specs (domain spec,
> PRD, behavioral contracts, architecture, verification properties), stories, and code.
>
> **Build mode:** greenfield (new layers) + Phase-0 brownfield extraction of vsdd-factory's
> own engine-neutral spine. **Authoring depth:** human provides brief + research; the
> pipeline crystallizes everything downstream.

## Core principle

> We do not "support N engines." We design **one engine-adapter protocol** and
> write **N adapters** against it. The factory core never knows the word "Unity."

This is the LSP / Terraform-provider / Kubernetes-CRI pattern: a stable protocol
in the middle, pluggable backends on the edge, a conformance suite that keeps
them honest.

## Layers

1. **Core orchestration engine** — extracted from vsdd-factory; engine- AND game-neutral.
2. **Game-factory methodology layer** — game agents, contract schemas, convergence dims, playtest/replay protocols, asset lane.
3. **Engine adapter protocol** — the anti-lock-in seam (capability manifest + command templates + result schema).
4. **Adapters** — one per engine (Bevy, Unity, Godot, …), each passing a conformance suite.

## Founding decision

Adapter protocol is being designed against **Bevy + Unity** (maximum
dissimilarity → hardest stress test). **Godot** is the confirmed cheap third
adapter (research-validated: between Bevy and Unity on 7/8 axes). Decisions:
- [`0001`](docs/decisions/0001-founding-engine-pair.md) — founding pair Bevy + Unity
- [`0002`](docs/decisions/0002-protocol-and-conformance-stance.md) — hybrid protocol + conformance (LSP + Terraform + CRI/CSI)
- [`0003`](docs/decisions/0003-determinism-tier-capability.md) — determinism tier as a capability dimension

**Research pass 1 is complete** — start with [`docs/research/RECONCILIATION.md`](docs/research/RECONCILIATION.md).

## Documents

- [`docs/design/architecture.md`](docs/design/architecture.md) — four-layer architecture
- [`docs/design/engine-adapter-protocol.md`](docs/design/engine-adapter-protocol.md) — the protocol, capability matrix, sample manifests
- [`docs/design/extraction-boundary.md`](docs/design/extraction-boundary.md) — what moves from vsdd-factory vs stays vs is built new
- [`docs/research/`](docs/research/) — cited evidence base (engine capability research + prior art)
- [`docs/decisions/`](docs/decisions/) — decision log
