# CORTEX — Complete User Guide

**CORTEX** is a local-first research capture app for the **Galaxy Z Fold 6**. It turns Chrome reading, shares, and drag-and-drop into an organized **scientific-method workspace** — not a scrapbook.

Everything lives on your device (Isar database + files under app storage). No account. No cloud sync (yet).

---

## 1. What CORTEX is for

Use CORTEX when you are:

- Learning a hard topic and collecting sources as you go  
- Running a literature review or security/biology/UX deep-dive  
- Testing a **hypothesis** against evidence you capture from the web  
- Keeping quotes, screenshots, PDFs, and links tied to claims you can score  

Chrome stays the browser. CORTEX is the **lab notebook**.

---

## 2. First launch & Fold setup

### Onboarding
On first open you get three steps:

1. **App Pair** — save Chrome + CORTEX as a Fold App Pair  
2. **Capture** — Share or drag into CORTEX  
3. **Organize** — projects, stages, claims  

Tap **ENTER CORTEX** to continue.

### Recommended Fold layout
1. Open **Chrome** and **CORTEX** in split-screen on the inner display.  
2. Tap the divider handle → save as an **App Pair** (Edge panel star).  
3. Later: one tap opens research left / CORTEX right.

Cross-app drag-and-drop only works in **true split-screen (or DeX) on a real device** — not in a single-window emulator session.

---

## 3. Core concepts (read this once)

| Concept | Meaning |
|--------|---------|
| **Project** | One research effort (e.g. “Rust async internals”, “Zero-trust mesh”). Formerly called “Topic”. |
| **Research question** | The headline question on the project card — what you are trying to answer. |
| **Stage** | A scientific-method bucket where items live (Question, Evidence, etc.). |
| **Research item** | Anything you capture: text, link, image, video, or file. |
| **Claim** | A first-class question / hypothesis / thesis you can attach evidence to. |
| **Stance** | How an evidence item relates to a claim: **Supports**, **Refutes**, or **Neutral**. |
| **Credibility** | How much you trust that source: High / Medium / Low / Unknown. |
| **Evidence balance** | Live score: how many items support vs refute a claim (weighted by credibility). |
| **References** | Auto list of sourced items (URLs / citations) for the project. |

---

## 4. Projects

### Projects screen (`PROJECTS` tab)
- Grid / list of **project cards**  
- Each card shows: title, research question, **9-dot stage progress**, item count, last updated  
- Lit dots = stages that already contain at least one item  
- Top bar: search, sort (**Recent** / **A–Z** / **Most items**)  
- FAB **+** → create a project  

### Create a project
1. Tap **+**  
2. Fill in:
   - **Title** (required) — e.g. `Rust async internals`  
   - **Research question** — e.g. `How does Tokio schedule work-stealing?`  
   - **Field** (optional) — e.g. `Systems`, `Security`  
   - **Description** (optional)  
   - **Accent color**  
3. Save — the project appears **immediately** (and survives app kill / relaunch).

### Edit / delete
Long-press a project card → edit details, reorder, or delete (deletes its items & claims).

### Two-pane (unfolded Fold)
Wider than ~840px: **Projects** on the left, **workspace** on the right. Tap a project to load it without leaving the shell.

---

## 5. Project workspace & research stages

Open a project to enter the **workspace**. Across the top is a stage rail:

**Overview** · Question · Background · Hypothesis · Method · Evidence · Analysis · Conclusion · Open Questions · References

### What each stage is for

| Stage | Put here |
|-------|----------|
| **Overview** | At-a-glance: research question, claims with evidence-balance chips, stage progress. Not a drop bucket itself. |
| **Question** | Driving research questions / what you are trying to learn. |
| **Background** | Literature, definitions, prior knowledge — most dragged articles land here or in Evidence. |
| **Hypothesis** | Working claims / theses / best-guess answers (you can also use formal **Claims** — see §7). |
| **Method** | How you will investigate: experiment design, reading plan, tools, procedure. |
| **Evidence** | **Default drop target.** Raw sources, quotes, images, data, screenshots. |
| **Analysis** | Your synthesis — patterns, connecting evidence to claims. |
| **Conclusion** | What you concluded / answered / learned. |
| **Open Questions** | Unresolved threads, follow-ups, next steps. |
| **References** | Auto-aggregated bibliography from items with a URL or citation. |

### Stage progress
The 9 dots on project cards (and in Overview) light up when that stage has ≥1 item. Use this to see “where the research is thick vs empty.”

### Filtering inside a stage
- Type chips: ALL / TEXT / LINKS / IMAGES / VIDEOS / FILES  
- Search box filters within the current stage  
- Tag chips (if you tagged items)  

### Manual add
FAB **+** in the workspace → add text, link, image, or file into the **current stage** (or pick a stage in the sheet).

---

## 6. Capturing content

CORTEX accepts:

| Type | Examples |
|------|----------|
| **Text** | Selected paragraphs, notes |
| **Link** | URLs, YouTube — preview + thumbnail fetched offline-cached |
| **Image** | Screenshots, photos |
| **Video** | Local video files (thumbnail generated) |
| **File** | PDFs, docs, etc. |

### A. Drag & drop (split-screen) — fastest

1. Put **Chrome** and **CORTEX** side-by-side.  
2. In Chrome: select text → **long-press the selection** and drag across the divider onto CORTEX.  
   - Or drag a link / image.  
3. Drop onto:
   - A **stage view** in an open project → **quick-add** into that stage (no sheet; snackbar + Undo).  
   - The **Projects** list / a project card → **Capture Sheet** opens so you can pick project, stage, and optional claim link.  

While dragging over CORTEX you should see the **JARVIS HUD** (brackets, scan grid, targeting reticle). That is visual only — it does not block the drop.

> Tip: initiate with **long-press on the selection**, then drag. A normal press-drag often fails on Android.

### B. Android Share
From Chrome / Gallery / Files → **Share → CORTEX**. Capture Sheet opens. Pick project + stage (and optional claim fields), save.

### C. Capture Sheet fields

| Field | Required? | Notes |
|-------|-----------|--------|
| **Project** | Yes | Which project receives the item |
| **Stage** | Yes | Defaults to **Evidence** |
| **Note** | No | “Why this matters” annotation |
| **Tags** | No | Comma-separated |
| **Link to claim** | No | Attach to a hypothesis/question |
| **Stance** | No | ▲ Supports / ● Neutral / ▼ Refutes |
| **Credibility** | No | High / Medium / Low / Unknown |

Rule of thumb: **project + stage only** for speed; claim linking when you already know which idea the source tests.

### D. YouTube & web links
Dropped/shared links:

- Are classified as **link** items  
- Fetch **title + thumbnail** (YouTube via oEmbed / `i.ytimg.com`; other sites via Open Graph)  
- Cache the image locally for offline cards  
- Appear in **References** with an auto citation string  

---

## 7. Claims — the deep-study engine

Claims are the feature that makes CORTEX a **study tool**, not a dump folder.

### Claim types

| Type | Use when |
|------|----------|
| **Question** | An open research question you want evidence against. |
| **Hypothesis** | A testable working claim (“X causes Y”, “API A is faster than B”). |
| **Thesis** | A stronger position you are defending in a paper / write-up. |

### How to add a claim
1. Open a project → **Overview** (or Claims entry from the workspace).  
2. Open the **Claims** panel → **Add**.  
3. Pick type + write the **statement**.  
4. Save.

Each claim shows:

- Status: **open** / **supported** / **refuted** / **inconclusive**  
- **Confidence** 0–100 (derived from evidence, weighted by credibility)  
- Balance chip like: `▲ 4 supports · ▼ 1 refutes`

### Linking evidence to a claim (the important workflow)

**Goal:** For any hypothesis, see whether the sources you captured actually back it.

1. Capture a source (drag, share, or manual add) into **Evidence** (or another stage).  
2. In the **Capture Sheet** (or later when editing the item):
   - **Link to claim** → pick the hypothesis  
   - Set **Stance**:
     - **▲ Supports** — this source backs the claim  
     - **▼ Refutes** — this source contradicts it  
     - **● Neutral** — related but doesn’t take a side  
   - Set **Credibility** (how much you trust the source)  
3. Save.

The claim’s **evidence balance** and **confidence** update automatically:

- High credibility counts more than low  
- Enough weighted support → status **supported**  
- Enough weighted refutation → **refuted**  
- Mixed → **inconclusive**  
- No stance-tagged evidence → **open**  

### Reading the balance
On Overview / Claims panel:

- Tap a claim to see its linked evidence grouped by stance.  
- Tap an evidence row to open that item.  

This is the loop: **capture → file → link to claim → watch the balance**.

---

## 8. Item cards & detail

### Cards show
- Media type badge (TEXT / LINK / IMAGE / …)  
- Body preview (quote, link title + thumb, image, etc.)  
- Relative time, tags, note snippet  
- On evidence: **stance badge** + **credibility** dot when linked  

### Item detail
Tap a card to:

- Edit note / tags / text  
- Change stage  
- Move to another project  
- Open source URL  
- Share / delete  

---

## 9. References

Open the **References** stage (or the aggregated references list in the workspace):

- Collects every item with a `sourceUrl` or `citation`  
- Citation is auto-built from cached link metadata (title, site, URL, capture date)  
- Useful for export / bibliography skim while writing  

---

## 10. Global search

Bottom nav → **Search**:

- Search across projects and items (text, notes, tags, titles, URLs)  
- Filter by media type and tag  
- Tap a project hit to open it; tap an item to open detail  

Works fully offline on local data.

---

## 11. Settings

Bottom nav → **Settings**:

- **Default capture project** — pre-selected in Capture Sheet  
- Accent / preferences (as available)  
- **Export / import** research archive (projects, claims, items, files)  

---

## 12. Suggested workflows

### A. Quick capture while reading (no claims yet)
1. App Pair Chrome + CORTEX.  
2. Open the project → **Evidence** stage.  
3. Drag selections / links onto the feed.  
4. Later: refile into Background / Analysis and link claims.

### B. Hypothesis-driven study
1. Create project with a clear research question.  
2. Add 1–3 **Hypothesis** claims.  
3. Capture sources into Evidence.  
4. For each important source: link claim + stance + credibility.  
5. Watch Overview — which hypothesis is actually supported?  
6. Write Analysis / Conclusion stages from the balance.

### C. Literature review
1. Drag papers/articles into **Background**.  
2. Key quotes → **Evidence**, tagged by theme.  
3. Claims as “themes” or theses.  
4. Use **References** when writing.

### D. Learning a hard topic
1. Research question = “What must I understand to use X?”  
2. Background = tutorials / docs.  
3. Open Questions = things you still don’t get.  
4. Hypothesis = “I think X works like Y” — then find evidence that supports or kills it.

---

## 13. JARVIS HUD (drag feedback)

When you drag over a capture surface:

1. **Enter** — corner brackets + scan grid + `ACQUIRING TARGET`  
2. **Track** — reticle follows the pointer; `DROP TO CAPTURE` when valid  
3. **Drop** — shockwave / particles; new card can “materialize”  
4. **Leave** — HUD retracts  

Visual only. Capture correctness does not depend on the FX.

---

## 14. Data & privacy

- Database: local **Isar** (`Project`, `Claim`, `ResearchItem`)  
- Files: relative paths under app documents (`cortex/<projectId>/…`, `cortex/previews/`, `cortex/thumbs/`)  
- Link previews need network once; after that cards can show cached images offline  
- Deleting a project removes its items and claims  
- Uninstalling the app removes local data unless you exported  

---

## 15. Troubleshooting

| Problem | Fix |
|---------|-----|
| Drag does nothing | Use **real device split-screen**; **long-press selection** then drag; drop onto feed/stage, not only the status bar. |
| Text won’t land | Chrome often sends HTML — CORTEX accepts plain text + HTML + URI. Check log for `onDropOver → copy`. |
| New project missing | Should appear via live watch. Force-stop and reopen; if schema just upgraded, first launch may wipe old Topic-era data. |
| No YouTube thumb | Needs network once; wait a second for enrichment; pull to refresh by leaving and re-entering the project. |
| Claim balance stuck at open | Evidence must be **linked to that claim** with Supports/Refutes — Neutral alone won’t move status much. |

---

## 16. Feature map (what’s built)

| Area | Status |
|------|--------|
| Projects CRUD + live persistence | ✅ |
| Scientific-method stages | ✅ |
| Drag-drop + Share capture | ✅ |
| JARVIS HUD FX | ✅ |
| Link / YouTube previews | ✅ |
| Claims + stance + credibility + balance | ✅ |
| Capture Sheet stage + claim link | ✅ |
| References aggregation | ✅ |
| Global search | ✅ |
| Export / import | ✅ |
| Onboarding + settings | ✅ |
| Cloud sync / accounts | ❌ not built |
| Multi-device | ❌ local only |

---

## 17. Quick cheatsheet

```
New project          → Projects tab → +
Open workspace       → tap project
Change stage         → stage chips on workspace
Quick drop           → drag onto open stage (inherits stage)
Careful drop         → drag onto Projects list → Capture Sheet
Add claim            → Overview / Claims → Add
Link evidence        → Capture Sheet → claim + ▲/▼ + credibility
See who’s winning    → Overview evidence-balance chips
Bibliography         → References stage
Find anything        → Search tab
```

---

*CORTEX — local research capture. Chrome for browsing. CORTEX for thinking.*
