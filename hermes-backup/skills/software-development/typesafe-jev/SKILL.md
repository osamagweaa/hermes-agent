---
name: typesafe-jev
description: Use TypeSafe Jev for calibrated text evaluation.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [typesafe, jev, evaluation, calibration, system-one]
    related_skills: [software-development]
---

# TypeSafe Jev Evaluation

## When to Use
Use this skill when you need to build automated evaluation pipelines, triage failures, or gate code reviews using calibrated, structured judgments rather than open-ended LLM reasoning.

TypeSafe Jev is a System One decision model that evaluates typed questions against a state (evidence) to return structured answers with calibrated probabilities. It is designed for fast, gut-check judgments rather than extended reasoning.

## Procedure

1. **Setup**
   - Install the plugin: `hermes plugins install ajensenwaud/hermes-jev-plugin`.
   - Configure the API key: Add `TYPESAFE_API_KEY` to `~/.hermes/.env`.

2. **Design the Rubric**
   - Decompose complex evaluation goals into atomic questions that a senior engineer could answer in seconds.
   - Assign a question type:
     - `noul`: For binary yes/no judgments.
     - `choice`: For picking exactly one option from a set.
     - `score`: For ratings on an ordered rubric.

3. **Execute Evaluation**
   - Use `jev_evaluate` to run multiple questions against the same state in one call (most efficient).
   - Use `jev_check` (noul), `jev_route` (choice), or `jev_score` (score) for individual atomic calls.

4. **Gate Actions**
   - Use probabilities and confidence to determine the next step:
     - `yes_probability >= 0.8` (or confidence >= 0.7) $\rightarrow$ act automatically.
     - `0.3` to `0.7` $\rightarrow$ surface to human or gather more context.
     - `yes_probability <= 0.2` $\rightarrow$ act on the negation.
   - Never hard-branch on values near 0.5.

## Pitfalls

- Use `hermes plugins install` for Jev, not `manage_connections` — the latter is for MCP servers and will fail for this plugin.
- Provide raw evidence as state, not summaries — Jev's calibration relies on seeing the actual artifact (e.g., raw diffs, logs, stack traces).
- Avoid asking for prose or explanations — Jev returns structured judgments, not text; asking for explanations is an anti-pattern.
- Decompose multi-factor questions — asking to "rate a PR" is unpredictable; ask about specific factors (e.g., "modifies auth", "has tests") and combine the results in code.
