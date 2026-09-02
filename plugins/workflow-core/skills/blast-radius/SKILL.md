---
name: blast-radius
description: Prove what a risky or cross-cutting change could break beyond its diff. Invoke explicitly for blast-radius analysis or when reviewing a small change whose hidden effects are the main concern.
---

# Blast radius

Find the one or two facts that determine whether the change is safe, then gather the strongest authorized evidence available.

## Workflow

1. Read the diff, changed contracts, and surrounding behavior.
2. Trace effects that symbol search can miss, including persisted data, wire formats, timing, configuration, feature flags, library behavior, and downstream consumers.
3. Separate confirmed risks, cleared risks, and assumptions that remain unproven.
4. Use existing tests and executable checks first.
5. Create a focused proof script or test only when the current request authorizes repository changes.
6. Do not mutate code during a review-only request.
7. Cite exact files and lines, and report where each important claim stopped on the evidence ladder.

## Evidence ladder

1. Reasoned assertion.
2. Supporting source location.
3. Demonstrated unreachable failure path.
4. Executed test or script.
5. Reproduction in the running product.

Do not round an unproven claim up to certainty.

Return the change's actual effect, the safety-critical facts and evidence level, confirmed risks, cleared risks, and the cheapest remaining check before merge.
