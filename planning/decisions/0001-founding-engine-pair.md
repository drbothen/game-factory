# Decision 0001 — Founding engine pair: Bevy + Unity

**Status:** Accepted
**Date:** 2026-06-07

## Context

The engine adapter protocol (Layer 3) must be designed against **two dissimilar
backends simultaneously** (the "two-adapter rule") — an abstraction designed
against a single engine leaks that engine's assumptions into the supposedly
neutral protocol.

## Decision

Design the protocol against **Bevy + Unity**.

## Rationale

Maximum dissimilarity = hardest stress test = most trustworthy abstraction:

- **Compiled-code-first (Bevy) vs editor/GUI-first (Unity).**
- **Render-while-headless-is-easy (Bevy offscreen render) vs
  render-while-headless-conflicts (Unity `-nographics`).** This single contrast
  forces the protocol to treat `capture` fidelity as independent of
  `run_headless` — a design correction we would have missed with a similar pair.
- **libtest JSON vs NUnit XML** test output forces the normalized result schema
  to be real, not optional.
- **Native ECS introspection vs editor-script DIY** forces `introspect` to be a
  graded capability, not a guarantee.

It is also the strongest no-lock-in proof: if the protocol survives an OSS Rust
engine and a commercial editor-centric engine, the rest interpolate.

## Consequences

- **Godot** becomes the planned cheap third adapter: it sits between Bevy and
  Unity on every axis, so it falls inside the envelope by construction. (Yes —
  Godot is supported; the architecture supports it for free, the adapter is a
  small implementation task.)
- **Unreal** remains the genuine Tier-3 outlier (headless/determinism/CLI pain),
  deferred until the protocol is proven.
- Unity adds licensing + heavier CI cost — accepted as the price of the strongest
  dissimilarity stress.

## Alternatives rejected

- Bevy + Godot — both headless-friendly; under-stresses the editor-centric axis.
- Godot + Unity — both scene-graph/editor-centric; risks editor-centric
  assumptions leaking into the "neutral" layer.
- Bevy + Web — very dissimilar but Web is a niche subset; doesn't represent the
  editor-centric majority of engines.
