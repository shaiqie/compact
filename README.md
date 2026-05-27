<div align="center">

<img src="https://img.shields.io/badge/version-1.0.0-0f0f0f?style=for-the-badge" alt="version"/>
<img src="https://img.shields.io/badge/compatible-Claude%20%7C%20GPT%20%7C%20Gemini-0f0f0f?style=for-the-badge" alt="compatible"/>
<img src="https://img.shields.io/badge/cost_reduction-~95%25-0f0f0f?style=for-the-badge" alt="cost reduction"/>
<img src="https://img.shields.io/badge/license-MIT-0f0f0f?style=for-the-badge" alt="license"/>

<br/><br/>

# compact

**Maximum token efficiency for AI coding agents and API pipelines.**
Three compounding layers. One skill. ~5–10% of naive baseline cost.

<br/>

[Overview](#overview) · [How It Works](#how-it-works) · [Installation](#installation) · [Usage](#usage) · [Reference](#reference)

</div>

---

## Overview

Most token-efficiency approaches only target output verbosity — trimming sentences, cutting filler words. That captures ~65–75% of possible savings and stops there.

`compact` attacks waste on all three fronts simultaneously:

| Layer | Target | Reduction |
|---|---|---|
| Output Style | Logical notation over prose | −65% output tokens |
| Code Output | Unified diffs over full rewrites | −80% code output |
| Input Compression | AST stubs + LLMLingua-2 pruning | −40–60% input tokens |
| Caching | Prompt cache on static context | −90% on repeated input |
| Batch Routing | Async batch API for non-interactive tasks | −50% financial cost |

Each layer is independent. All five together compound to **~5–10% of naive baseline cost** on long agentic pipelines.

---

## How It Works

### Layer 1 — Output Style: Logical Notation

`compact` replaces grammatical prose with logic-notation, symbols, and telegraphic tokens. Three tiers scale to context.

**Symbol vocabulary:**

| Symbol | Meaning |
|--------|---------|
| `→` | implies / leads to |
| `∴` | therefore |
| `∵` | because |
| `!` | negation / not |
| `&&` / `\|\|` | and / or |
| `Δ` | change / delta |
| `⚠` | warning |
| `✦` | fix / solution |
| `∅` | null / undefined |

**Compression tiers:**

```
Tier 1 — Conversational shorthand (default)
  Omit articles, filler, hedges. Nouns + verbs + key qualifiers only.

Tier 2 — Logic notation (explanations, debugging, architecture)
  Swap prose for conditional syntax and symbol chains.

Tier 3 — Telegraphic (agentic loops, tool calls, confirmations)
  Single-line status bursts. No explanation unless error.
```

**Side-by-side comparison:**

| Style | Output | Tokens |
|-------|--------|--------|
| Vanilla | "The component is re-rendering because your prop reference is changing. You should wrap it in a useMemo hook to prevent this behavior." | ~35 |
| Caveman | "New object ref each render. Inline prop = new ref = re-render. Use useMemo." | ~15 |
| **compact Tier 1** | `prop change → re-render. ✦ useMemo(obj)` | **~8** |
| **compact Tier 2** | `obj ref Δ/render → re-render. ✦ useMemo(() => obj, [deps])` | **~10** |

---

### Layer 2 — Code Output: Minified Unified Diffs

`compact` never outputs full rewritten files. All code changes use a strict search-and-replace diff format — only the exact lines being altered, nothing else.

**Diff format:**

```
<<<FIND>>>
<exact original lines, 1–2 lines of surrounding context>
<<<REPLACE>>>
<new lines>
<<<END>>>
```

Stack multiple blocks for multi-site changes. Empty `<<<REPLACE>>>` block for deletions.

**Full file output is only justified when:**
- File is fewer than 30 lines total
- User explicitly requests the full file
- More than 60% of lines change (diff would exceed the file)

**AST stubs for codebase context:**

When referencing code structure in a reply, `compact` outputs signature-only stubs via Tree-sitter — not full source:

```typescript
// FILE: src/auth/service.ts [stub — 847 lines]
interface AuthConfig { ... }
class AuthService {
  constructor(config: AuthConfig)                              // line 12
  async login(creds: Credentials): Promise<TokenPair>         // line 18
  async refresh(token: string): Promise<string>               // line 29
  private validate(token: string): boolean                    // line 41
}
```

Strips: docstrings, inline comments, implementation bodies, unrelated imports.
Token reduction per file: **60–80%.**

---

### Layer 3 — Infrastructure: API-Level Cost Compounding

#### Prompt Caching

Structure prompts so static content (system prompts, codebase stubs, CLAUDE.md guidelines) sits at the top of context and is marked cacheable.

```python
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    system=[
        {
            "type": "text",
            "text": LARGE_STATIC_CONTEXT,
            "cache_control": {"type": "ephemeral"}
        }
    ],
    messages=[{"role": "user", "content": user_message}]
)
```

Savings: up to **90% reduction** on the static portion of every subsequent call.
Break-even: after ~1.4 reads (writes billed at 1.25x, reads at 0.1x).

#### LLMLingua-2 Semantic Pruning

Run accumulated conversation history and bash logs through LLMLingua-2 before re-injecting into context. Strips low-mutual-information tokens while preserving named entities, conditionals, and negations.

```python
from llmlingua import PromptCompressor

compressor = PromptCompressor(
    model_name="microsoft/llmlingua-2-bert-base-multilingual-cased-meetingbank",
    use_llmlingua2=True,
    device_map="cpu"
)

compressed = compressor.compress_prompt(context, rate=0.5)
```

**Rate guide by context type:**

| Context | Rate | Reduction |
|---------|------|-----------|
| Bash history / terminal logs | 0.30–0.40 | ~60–70% |
| File read dumps | 0.40–0.50 | ~50–60% |
| Conversation history | 0.50–0.60 | ~40–50% |
| Error tracebacks | 0.60–0.70 | ~30–40% |
| Code / diffs | 0.80+ | Do not compress |

#### Batch API Routing

Route all non-interactive tasks through the Batch API for a flat 50% cost reduction.

```
Use batch for:                          Skip batch for:
  Automated code review                   Interactive chat / REPL
  Bulk test generation                    Real-time completions
  Structural refactoring passes           Streaming responses
  CI/CD lint + suggestion pipelines
  Nightly analysis runs
```

Anthropic: `client.beta.messages.batches.create()`
OpenAI: `client.batches.create(endpoint="/v1/chat/completions")`

---

## Pipeline Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                   Prompt Caching Engine                      │
│              Saves ~90% on repeated static context           │
└────────────────────────────┬─────────────────────────────────┘
                             │
┌────────────────────────────▼─────────────────────────────────┐
│              Input / Output Compression Pipeline             │
├──────────────────────────────┬───────────────────────────────┤
│  Input: LLMLingua-2 pruning  │  Output: Logical notation     │
│  + Tree-sitter AST stubs     │  + Minified unified diffs     │
│  −40–60% input tokens        │  −65–80% output tokens        │
└──────────────────────────────┴───────────────────────────────┘
                             │
┌────────────────────────────▼─────────────────────────────────┐
│                    LLM Batch API                             │
│              Flat 50% financial cost reduction               │
└──────────────────────────────────────────────────────────────┘
```

---

## Installation

Install as an AI skill (Claude Skills format):

1. Download `compact.skill`
2. Open Claude Settings → Skills → Install from file
3. Select `compact.skill`

The skill loads automatically when token efficiency, cost reduction, or agent optimization is relevant to the task.

---

## Usage

### Activating compact mode

Once installed, `compact` triggers automatically on phrases like:

- "save tokens", "reduce costs", "token efficient"
- "compact mode", "minimize API spend", "cheaper AI"
- "coding agent", "agentic loop", "batch processing"
- "optimize prompts", "slim context", "compress output"

Type `/compact` to activate explicitly in any session.

### Deactivating

```
"turn off compact"    → reverts to standard output style
"write normally"      → same
"go full compact"     → forces Tier 3 (telegraphic) for everything
```

### Behavioral rules when active

```
No preamble          Never starts with "Sure!", "Great question", or task restatement
No postamble         Ends at the answer — no "let me know if you need anything else"
No filler            Cuts: "basically", "essentially", "in order to", "it's worth noting"
Diffs over files     Always, unless the three exceptions apply
One-line confirms    Tool/agent steps: "✓ done." not a paragraph
Error format         "⚠ [ERROR TYPE]: <1-line cause> → <1-line fix>"
```

---

## Repository Structure

```
compact/
├── README.md
└── skills/
    ├── SKILL.md
    └── references/
        ├── ast-trimming.md
        ├── llmlingua-usage.md
        └── batch-api.md
```

---

## Reference

| File | Contents |
|------|----------|
| `skills/SKILL.md` | Core instructions: all three layers, symbol vocabulary, behavioral rules |
| `skills/references/ast-trimming.md` | Tree-sitter patterns for Python, TypeScript, Go, Rust; threshold guide |
| `skills/references/llmlingua-usage.md` | LLMLingua-2 integration, rate calibration, agentic loop pattern, failure modes |
| `skills/references/batch-api.md` | Full Anthropic + OpenAI batch API implementations, prompt caching setup, combined pipeline |

---

## Cost Model

Baseline (no optimization) = 100%

| Optimization | Applies to |
|---|---|
| Compact output — Tier 1/2 notation | −65% output tokens |
| Unified diffs — no full rewrites | −80% code output tokens |
| AST stub injection | −60% code input tokens |
| LLMLingua-2 history compression | −50% prose input tokens |
| Prompt caching on static context | −90% cached input tokens |
| Batch API routing | −50% total financial cost |

<div align="center">

**Compounded effective cost on a long agentic pipeline: ~5–10% of baseline.**

<br/>

<img src="https://img.shields.io/badge/built_for-Claude%20Skills-0f0f0f?style=for-the-badge" alt="built for Claude Skills"/>
<img src="https://img.shields.io/badge/LLMLingua--2-integrated-0f0f0f?style=for-the-badge" alt="LLMLingua-2"/>
<img src="https://img.shields.io/badge/Tree--sitter-integrated-0f0f0f?style=for-the-badge" alt="Tree-sitter"/>

</div>

---

<div align="center">
MIT License
</div>
