---
document_type: verification-property
level: L3
version: "1.0"
status: draft
producer: architect
timestamp: 2026-06-08T00:00:00Z
phase: 1b
vp_id: VP-009
formal_method: proptest
priority: P0
owning_subsystem: SS-05
traces_to:
  - .factory/specs/behavioral-contracts/ss-06/BC-6.01.002.md
  - .factory/specs/domain-spec/invariants.md#DI-012
inputs:
  - .factory/specs/behavioral-contracts/ss-06/BC-6.01.002.md
input-hash: "[compute via bin/compute-input-hash at pipeline ingest]"
---

# VP-009: Damage I/O Matrix Row-Sum Correctness

## Property Statement

For every declared damage type and target entity class pair `(DType, EClass)` in
the damage I/O matrix, the computed damage output must lie within the declared
`[min_dmg, max_dmg]` range for all valid input combinations.

Additionally, for damage interactions with declared total-damage-preserved semantics
(e.g., area damage split across multiple targets), the sum of per-target damage must
equal the declared total damage within floating-point epsilon.

Formally: let `D(dtype, eclass, modifiers)` be the damage function.
For all valid modifier combinations:

```
min_dmg(dtype, eclass) ≤ D(dtype, eclass, modifiers) ≤ max_dmg(dtype, eclass)
```

And for split-damage: `Σ_i D_i = D_total ± ε`.

## Formal Method Candidate

**proptest (property-based testing)**

Strategy:
```rust
proptest! {
    #[test]
    fn damage_matrix_in_range(
        dtype in damage_type_strategy(),
        eclass in entity_class_strategy(),
        modifiers in damage_modifier_strategy(),
    ) {
        let (min_dmg, max_dmg) = DAMAGE_MATRIX.bounds(dtype, eclass);
        let result = compute_damage(dtype, eclass, modifiers);
        prop_assert!(result >= min_dmg && result <= max_dmg);
    }
}
```

## Feasibility Assessment

**Feasibility: HIGH.** The damage function is a pure arithmetic function of declared
inputs. The damage I/O matrix is a first-class design artifact (authored by
`combat-designer` in Wave 0); its declared bounds are testable constants. proptest
is ideal for exploring the modifier space. The main risk is that modifier combinations
produce out-of-bound results due to multiplicative stacking; this is precisely what
this VP is designed to catch before ship. Split-damage preservation is straightforward
floating-point arithmetic.

## BC Traceability

- BC-6.01.002 (Damage I/O Matrix Correctness) — direct counterpart.

## Purity Classification

**Pure Core.** Damage computation is a pure arithmetic function: `(DType, EClass,
Modifiers) → DamageValue`. No I/O, no random number generation in the formula
itself (crits may be resolved before input, treated as input modifiers).
