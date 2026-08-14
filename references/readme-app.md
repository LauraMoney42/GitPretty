# README shape: app, tool, or portfolio project

For a repo whose source is public and whose reader arrives wanting to **see what
it does**, run it, or judge whether the author can build. Two related variants
are covered here:

- **App or tool**: someone might actually run this. Web apps, desktop apps,
  agents, services, games
- **Portfolio project**: nobody will run it, and it exists as evidence of skill.
  Course projects, experiments, things built to learn something

They share a section order and differ in emphasis, noted per section.

## The rule that matters

**A screenshot or GIF goes near the top.** Unlike a library, the reader here is
deciding whether the thing is real and interesting before deciding whether to
use it. A repo with a hero image reads as finished; the same repo without one
reads as a work in progress, even when the code is identical.

Do not push the run instructions far down, though. Someone who wants to try it
should find the command without hunting.

## Section order

| # | Section | App | Portfolio |
|---|---------|-----|-----------|
| 1 | Name and tagline | Both |
| 2 | Badges | Stack, license, CI | Stack only |
| 3 | Hero image or GIF | Both, near the top |
| 4 | What it is | 2 to 3 sentences | Include why it was built |
| 5 | Run it | Full setup | Short, or "not deployed" |
| 6 | Features or screens | Screenshot table | Screenshot table |
| 7 | The hard part | Optional | **The main event** |
| 8 | Architecture | Diagram plus table | Diagram plus table |
| 9 | Status and roadmap | What is next | What you would do next |
| 10 | License and credits | Both |

## 1 to 3: header and hero

```html
<h1 align="center"><name></h1>
<p align="center"><i><one line, concrete, no marketing adjectives></i></p>

<p align="center">
  <img alt="Stack" src="https://img.shields.io/badge/<lang>-<version>-635BFF?style=flat-square">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-4CCC93?style=flat-square">
</p>

<p align="center">
  <img src="media/demo.gif" width="640" alt="<what the GIF shows>">
</p>
```

Width 640 suits a desktop or web app; use 270 for a phone screencast. A relative
`.mp4` does not produce a player on GitHub, so if there is a longer video, link
it under the GIF.

## 4: what it is

Two or three sentences, in the vocabulary of someone who has the problem rather
than someone who built the solution.

For a portfolio project, add one sentence on **why it was built**. "Built to
learn how X works, after Y kept failing at Z" turns a toy into evidence of
curiosity and gives the reader a frame for judging the scope.

## 5: run it

For an app, make this genuinely complete and actually try it in a clean checkout.
Missing an env var or a migration step here is the most common defect:

```markdown
## Run it

​```bash
git clone https://github.com/<owner>/<repo>.git
cd <repo>
<install command>
cp .env.example .env    # <what needs filling in>
<run command>
​```

Then open http://localhost:<port>.
```

Ship the `.env.example`, and never the `.env`.

For a portfolio project that cannot be run easily, say so plainly rather than
publishing instructions that fail: "Needs an Apple Developer account and a
physical device; the demo above shows it running." Honesty here costs nothing
and a broken quickstart costs credibility.

## 6: features or screens

A three-column table of the main screens, then a two-column table for secondary
ones. Use `<img width="230">`; percentage widths do not work inside GitHub
markdown tables.

```markdown
| <caption> | <caption> | <caption> |
|:---:|:---:|:---:|
| <img src="screenshots/<name>.png" width="230"> | <img src="screenshots/<name>.png" width="230"> | <img src="screenshots/<name>.png" width="230"> |
```

Captions say what the screen does for the user, not what the control is called.
"Swipe left to skip, right to keep" beats "main deck view."

Every caption must match its file. Contact sheet the set and check, per
`media.md`.

## 7: the hard part

**For a portfolio project this is the most important section on the page**, and
usually the reason the repo is worth linking at all. The code shows what was
built; this shows what was understood.

Name the thing that was genuinely difficult, what the obvious approach was, why
it failed, and what replaced it. One specific bug with a number in it does more
than three paragraphs of description:

```markdown
## The hard part

<The constraint or bug, stated plainly.>

<The obvious approach, and why it was obvious.> <What actually happened when it
was tried: the specific failure, with the measurement or symptom.> <What
replaced it, and what that cost.>
```

For a shipped app, the equivalent is the limit you could not engineer around,
and how the UI handles it honestly. That is the least fakeable thing on a page.

## 8: architecture

A mermaid diagram, a component table with one line each, and two to four
decisions with reasoning. Since the source is public here, link to the real
files: `[`Scheduler`](src/core/scheduler.ts)` lets a reader check the claim in
one click, which is worth more than the claim itself.

See the mermaid gotchas in the skill body. Every number in this section comes
from the source, verified, not from an older doc.

Also list what was deliberately not built. It reads as judgment rather than
omission.

## 9: status and roadmap

Be explicit about the state, because ambiguity reads as abandonment:

```markdown
> **Status:** <in active development / stable / archived, kept for reference>
```

For a portfolio project, framing the roadmap as "what I would do next, and why I
stopped here" is stronger than a list of unbuilt features. It shows the scope
was a choice.

## 10: license and credits

Name the license and credit anything meaningfully borrowed: a tutorial the
project started from, an algorithm, a design. Attribution is cheap and its
absence is noticed.

A public repo with no license file means nobody may legally use the code. See
`repo-polish.md`.
