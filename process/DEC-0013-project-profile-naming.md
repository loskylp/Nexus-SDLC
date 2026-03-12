# DEC-0013: Project Profile Naming

**Status:** Accepted
**Date:** 2026-03-12
**Deciders:** Nexus Method Architect, Nexus (Human)

## Context

The framework needs a way for the Methodologist agent to classify projects by stakes and scale, and for that classification to directly determine the weight of artifacts the swarm produces. DEC-0008 used Crystal's C0-C3 scale and RUP's complexity labels, which are precise but require documentation lookup to interpret. The naming should be self-describing in plain conversation.

Crystal Methods (Cockburn, 2004 — cited in REFERENCES.md) is the acknowledged inspiration for classifying projects by criticality and team size. The names here are original to Nexus SDLC to avoid copyright dependency and to be more immediately legible.

## Decision

Four project profiles, named by stakes. Each profile has a corresponding artifact weight that describes the level of documentation rigor the swarm produces. The two dimensions are independent but conventionally paired.

### Profiles (Stakes)

| Profile | Criticality | Typical Scale |
|---|---|---|
| **Casual** | Failure causes discomfort | Solo developer / Proof of concept |
| **Commercial** | Failure causes loss of money | Small team / Internal tooling |
| **Critical** | Failure causes essential operations failure | Team / Product |
| **Vital** | Failure causes loss of life | Multi-team / Regulated system |

### Artifact Weights (Documentation Rigor)

| Artifact Weight | What It Means |
|---|---|
| **Sketch** | Minimal documentation. Brief notes, inline comments, lightweight plans. Just enough to orient the next agent invocation. |
| **Draft** | Working documentation. Structured plans, documented decisions, test plans. Enough to onboard a second contributor. |
| **Blueprint** | Full documentation. Formal requirements, architecture documents, traceability matrix, comprehensive test plans. Enough to survive team turnover. |
| **Spec** | Specification-grade documentation. Formal verification artifacts, regulatory compliance documents, audit-ready traceability. Enough to satisfy an external auditor. |

### Conventional Pairing

The default pairing is diagonal — Casual/Sketch, Commercial/Draft, Critical/Blueprint, Vital/Spec. But profiles and artifact weights can be mixed when circumstances warrant. A Casual project with regulatory reporting needs might produce Draft-weight artifacts for compliance sections only. The Methodologist makes this call.

### Usage

In conversation between the Methodologist, the Orchestrator, and the Nexus, classification is natural language:

- "This is a Casual project. The swarm will operate in Sketch mode."
- "This is a Critical project. The swarm will operate in Blueprint mode."

No jargon lookup required. The terms are self-evident.

## Rationale

**Why four levels, not three or five:** Four maps to the four natural breakpoints in consequence severity (discomfort / money / operations / life) and roughly corresponds to Crystal's four-level criticality scale. Three would merge "money" and "operations" which have meaningfully different risk profiles. Five would add distinctions without practical value.

**Why separate profiles from artifact weights:** Stakes and documentation rigor are correlated but not identical. A solo developer building a medical device prototype (Vital/Sketch transitioning to Vital/Spec) needs different handling than a team building an internal dashboard (Commercial/Draft). Separating the dimensions gives the Methodologist flexibility.

**Why plain English names:** Crystal uses C0-C3 codes. RUP uses "Inception/Elaboration/Construction/Transition." These require training to interpret. "Casual" and "Blueprint" mean what they say. The framework should be usable by someone who has never read a methodology textbook.

**Why acknowledge Crystal explicitly:** Intellectual honesty. The four-level stakes classification is Cockburn's insight. The names are ours, the structure is his.

## Consequences

**Easier:**
- Project classification takes one sentence, not a rubric
- Artifact weight immediately tells every agent how much documentation to produce
- The Methodologist's output is human-readable without framework knowledge

**Harder:**
- The boundary between profiles (e.g., Commercial vs. Critical) requires judgment from the Methodologist
- Mixed pairings (e.g., Commercial project with Blueprint-weight security artifacts) add nuance the Methodologist must handle

**Newly constrained:**
- All artifact filenames, agent instructions, and Methodologist output must use these profile and artifact-weight terms
- The Methodologist's final statement to the Nexus is always: "This is a [Profile] project. The swarm will operate in [ArtifactWeight] mode."
- DEC-0008 (Swarm Pattern Assessment) should be read through this lens — its C0-C3/Simple-Complex taxonomy is superseded by these profile names

## Alternatives Considered

**Crystal's original C0-C3 codes:** Precise and well-known in methodology circles but opaque to practitioners who have not read Cockburn. "C2" means nothing without context. Rejected for requiring documentation lookup.

**Traffic-light metaphor (Green/Yellow/Red):** Intuitive but only three levels and carries "stop/go" connotations that do not map to documentation weight. Rejected for insufficient granularity and misleading metaphor.

**Numeric scales (Level 1-4):** Compact but meaningless without a legend. "Level 3" tells you nothing. Rejected for the same reason as C0-C3.
