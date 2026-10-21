---
name: empire-ui-standards
description: \"Use for Empire UI design. Decision-First philosophy.\"
---

# Empire UI Standards

Operational surfaces in the Empire are not data viewers; they are **Decision Engines**. The goal is to minimize cognitive load and maximize decision speed.

## The 'Command Deck' Philosophy

Every interface must prioritize the **Decision** over the **Data**. If a user has to analyze a table or a log to figure out what to do, the UI has failed.

### 1. Decision-First Layout
- **Focus:** Present one decision at a time.
- **The Card Pattern:** Use a focused card for pending actions.
    - **Headline:** A clear question (e.g., \"Follow up with [Lead Name]?\").
    - **The Signal:** A concise 'Why' (e.g., \"New lead, 30 days since update\").
    - **Binary Action:** Large, distinct [YES] and [NO] buttons.
- **Transition:** Decisions must slide away instantly upon resolution to promote the next item.

### 2. High-Signal Status (The Pulse)
Avoid detailed status tables. Use a 'Pulse' bar:
- **Indicators:** Glowing status lights (Green/Yellow/Red) per project.
- **Meaning:** 
    - Green: Healthy/Quiet.
    - Yellow: Pending decisions.
    - Red: Critical error (e.g., source down).

### 3. Aesthetics & Ergonomics
- **Visual Style:** High-contrast Dark Mode (Linear/Obsidian aesthetic).
- **Palette:** Deep charcoal backgrounds with neon accents for status/actions.
- **Density:** Zero wasted pixels. No fluff. No generic 'Welcome' messages.
- **Live Feed:** A bottom-docked, terminal-style log for real-time agent activity (timestamped events).

## Pitfalls
- **The Data Viewer Trap:** Do not build pages that just display JSON or database rows. Synthesize that data into a decision card.
- **The Analysis Gap:** Never require the user to 'understand' the state of the system before they can act. The 'Why' must be explicit and brief.
- **Friction in Approval:** Avoid multi-step approval processes. One click = one action.
