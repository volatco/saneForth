# Two-Week Go Exploration Plan

## Scope and constraints

- Goal: decide whether to pursue incremental Go adoption for tooling/runtime-adjacent components.
- Non-goal: rewrite FORTH media or core runtime behavior in two weeks.
- Safety: do not line-edit `af3/sfux/*`, `Projects/*/*.src`, `Project`, `4THDISK`, `*.blk`, `OBJ-*`, `conc`.
- Keep all exploration additive and documentation-first.

## Success criteria

Decision quality after 2 weeks is the primary output. A "go" requires all of:

- Measurable improvement in at least one key metric:
  - host startup latency
  - serial connection reliability
  - operator error rate in connect flow
  - diagnostics clarity / time-to-triage
- No observed regression against golden behavior checks.
- Clear migration seam that avoids immediate core media rewrite.
- Team agreement on maintenance cost and ownership.

## Baseline metrics (capture before any Go spike)

Track values in `docs/modernization-baseline.md`:

- `make check-env` elapsed time
- `make doctor` elapsed time
- `make connect` time to first actionable prompt
- successful connect attempts / total attempts (Port_B bench)
- failure modes observed (`dialout`, wrong port, no banner, timing misses)

Run each workflow at least 5 times to reduce one-off noise.

## Week 1: Observe and constrain

### Day 1-2: behavior freeze and instrumentation

- Document canonical operator path from README and playbook.
- Capture golden transcripts for:
  - host boot smoke test
  - Volatco connect flow
  - at least 3 common failure modes
- Add lightweight timing wrappers in `scripts/` (no media edits).

Artifacts:

- `docs/modernization-baseline.md`
- `docs/golden-transcripts/*.md`
- `docs/failure-catalog.md`

Acceptance gate:

- Baseline metrics and transcripts exist, reproducible, and reviewed.

### Day 3-4: hotspot and risk mapping

- Identify where time is spent: shell startup, binary launch, serial setup, human steps.
- Build risk map:
  - High risk: media semantics, block image behavior, target protocol assumptions.
  - Medium risk: launch/connect orchestration.
  - Low risk: diagnostics and environment validation tooling.

Artifacts:

- `docs/perf-observations.md`
- `docs/risk-map.md`

Acceptance gate:

- Candidate Go seam selected from low/medium-risk area with explicit rationale.

### Day 5: spike design review

- Define an isolated Go spike with strict interface boundaries.
- Suggested spike: Go "doctor/connect assistant" that validates environment and preflights serial conditions before entering saneForth.

Artifacts:

- `docs/spike-design.md`
- decision log in `docs/decision-log.md`

Acceptance gate:

- Scope approved: no direct mutation of FORTH media, no runtime core replacement.

## Week 2: Build and evaluate one spike

### Day 6-8: implement minimal Go spike

- Create a separate tool (e.g. `tools/volatco-assist-go/`) that:
  - checks serial visibility and permissions
  - detects likely Port_B adapter identity
  - emits deterministic next-step guidance for operator
- Keep existing scripts intact; run new tool side-by-side.

Artifacts:

- Go prototype code
- README for prototype usage
- sample outputs for success and failure paths

Acceptance gate:

- Tool runs on repo host and covers the top 3 observed failure modes.

### Day 9: conformance checks

- Compare prototype outcomes with existing `make doctor`/`make connect` guidance.
- Validate parity against golden transcripts where applicable.
- Record mismatches and whether they are acceptable improvements or regressions.

Artifacts:

- `docs/spike-conformance.md`

Acceptance gate:

- No unexplained behavior differences in supported paths.

### Day 10: decision day

- Summarize measured deltas and confidence level.
- Make one decision:
  - `GO_INCREMENTAL`: continue with Go for tooling/orchestration only.
  - `HOLD`: keep shell/docs improvements only; defer Go expansion.
  - `NO_GO`: stop Go track for now.
- Define next 30-day backlog only if `GO_INCREMENTAL`.

Artifacts:

- `docs/two-week-outcome.md`
- updated `docs/decision-log.md`

Acceptance gate:

- Decision documented with evidence, tradeoffs, and owner.

## Recommended guardrails

- Never replace the current `make` workflow during the 2-week window.
- Feature-flag new tooling; keep rollback to existing scripts as default.
- Every spike claim must tie to a baseline metric delta.
- If data is inconclusive, choose `HOLD` and tighten measurement.

## Suggested owner checklist

Daily:

- Log runs and failures in baseline file.
- Keep a short "what changed today" note.

End of week 1:

- Confirm selected seam is still low/medium risk.

End of week 2:

- Ship decision memo and next-step recommendation.
