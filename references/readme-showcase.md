# README shape: showcase page for a private app

For a repo whose whole job is to prove an app is real without publishing its
source. The reader is a hiring manager or a prospective client, they will spend
about two minutes, and they cannot check anything by running it. So the page
front-loads proof and back-loads engineering.

## First: is publishing allowed?

Skip this only if the project is entirely the user's own. For anything built for
an employer or client, the screenshots, architecture, and product decisions are
usually theirs, not the author's. Ask directly whether permission exists, and if
the answer is unclear, say so rather than proceeding. A showcase repo that
causes trouble is worse than no showcase repo.

Three middle grounds when the answer is no or uncertain:

- Describe the problem shape and the decisions without naming the employer,
  showing their UI, or reproducing their data model
- Rebuild a small standalone demo of the interesting technique and publish that,
  which is the author's outright
- Keep the repo private and share the link directly with interviewers

## Layout

```
AppName-public/
  README.md
  .gitattributes          # *.png *.gif *.mp4 binary
  media/
    appname-demo.gif      # hero, autoplays in the README
    appname-demo.mp4      # full quality, linked not embedded
  screenshots/
    gestures.png love.png nope.png keep.png filters.png
```

Name screenshots for what they show, not `01-`, `02-`. Humans read this README
and the filenames land in alt text.

## The template

The section order and the markup that actually renders on GitHub. Fill it in
from the private repo's source, not its docs.

Angle-bracket placeholders like `<AppName>` are for substitution. Delete any
section that genuinely does not apply rather than leaving a stub.

## Section order and why

Front-load the proof, back-load the engineering. A reviewer decides in about
fifteen seconds whether to keep scrolling, so the GIF has to be near the top, and
the section they read closely (architecture) comes after they are already
convinced the thing is real.

| # | Section | Job it does |
|---|---------|-------------|
| 1 | Title and tagline | What it is, in one line |
| 2 | Attribution | Ownership claim, where a skimmer sees it |
| 3 | Badges | Platform, language, and the two facts that stand out |
| 4 | Status | Shipped, in review, or internal |
| 5 | Demo | The GIF, then the mp4 link |
| 6 | The problem | Why anyone wanted this |
| 7 | The app | Screenshot tables with captions |
| 8 | The hard constraint | The most credible section on the page |
| 9 | Architecture | The section they actually read |
| 10 | Roadmap | Deferred work, framed as scope control |
| 11 | About | Who built it, and that the source is private |

## 1 to 3: header block

Attribution goes directly under the tagline, not at the bottom. It is an
ownership claim on a public page, so it belongs where a skimmer sees it.

```html
<h1 align="center"><AppName></h1>
<p align="center"><i><one-line tagline, no marketing adjectives></i></p>
<p align="center">
  Built by <a href="https://github.com/<HANDLE>"><b><Full Name></b></a>
</p>
<p align="center">
  <img src="https://img.shields.io/badge/platform-iOS%2017%2B-black">
  <img src="https://img.shields.io/badge/language-Swift%205.9-orange">
  <img src="https://img.shields.io/badge/dependencies-none-brightgreen">
  <img src="https://img.shields.io/badge/networking-none-brightgreen">
</p>
```

Lead the badge row with platform and language, then the two that make a reviewer
pause. `dependencies-none` and `networking-none` are strong because they are
checkable claims about engineering discipline. Only use them if they are true.

## 4: status line

A blockquote, right under the badges. Pick the one that matches:

```markdown
> **Live on the App Store:** [<AppName>](<store-url>)
```

```markdown
> Submitted to the App Store, in review. Store link goes here once it is live.
```

```markdown
> Internal tool, in production since <Month Year>.
```

Never leave this ambiguous. "Coming soon" with no date reads as abandoned.

## 5: demo

A relative `.mp4` path does not produce a player on GitHub. The GIF is the
visible hero and the mp4 is a link underneath. This is not worth fighting.

```html
<p align="center">
  <img src="media/<appname>-demo.gif" width="270" alt="<what the GIF shows>">
</p>
<p align="center">
  <a href="media/<appname>-demo.mp4"><b>▶ Watch the full <N>-second demo</b></a>
</p>
```

## 6: the problem

Two or three sentences on the user's actual pain, in their language, before any
mention of the solution. Concrete beats general: a specific frustrating moment
lands harder than a category of problem.

## 7: the app

A three-column table for the core screens, then a two-column table for secondary
ones. Use `<img width="230">`. Percentage widths do not work inside GitHub
markdown tables.

```markdown
| <caption> | <caption> | <caption> |
|:---:|:---:|:---:|
| <img src="screenshots/<name>.png" width="230"> | <img src="screenshots/<name>.png" width="230"> | <img src="screenshots/<name>.png" width="230"> |
```

Captions describe what the screen does for the user, not what the control is
called. "Swipe left to skip, right to keep" beats "main deck view".

Every caption must match its file. Contact sheet the set and check, per step 3
of the skill.

## 8: the hard constraint

Every app has one thing it could not do: a platform limit, a privacy boundary, a
performance ceiling, an API that does not exist. Name it, explain why it is
unfixable, and show how the UI handles it honestly.

This is the most credible section on the page, because it is the one a reviewer
cannot get from a screenshot and the one that would be easiest to hide.

```markdown
## The hard constraint

<Framework/platform> does not <the thing>. <One sentence on why.>

<What the app does instead, and what the user sees.> <How the UI is honest about
the limit rather than papering over it.>
```

## 9: architecture

Three parts, in this order.

**A mermaid diagram.** GitHub renders ```` ```mermaid ```` natively. Use
`flowchart LR` at the top level, keep node labels plain, and avoid single-node
subgraphs. The full gotcha list is in the skill body.

```
flowchart LR
    subgraph V["Views"]
        A[<Screen>]
    end
    subgraph S["Services, sole owner of system access"]
        B[<Service>]
    end
    subgraph F["Platform frameworks"]
        C[<Framework>]
    end
    A --> B
    B --> C

    style V fill:#635BFF22,stroke:#635BFF
    style S fill:#4CCC9322,stroke:#4CCC93
    style F fill:#88888822,stroke:#888888
```

Replace the hex colors with the app's own palette so the page looks like the
product. The `22` suffix is alpha, which keeps the fills readable in both light
and dark themes.

**A service responsibility table.** One row per service, one line each. This is
where the descriptions live, since they cannot go inside node labels.

```markdown
| Service | Responsibility |
|---|---|
| `<Name>` | <One line. What it owns, not how it works.> |
```

**Two to four decisions with reasoning.** Each one covers what was done, what
the obvious alternative was, and what broke when it was tried. A real bug that
got fixed is worth more than any adjective.

```markdown
### <Decision, stated as the choice made>

<The obvious alternative, and why it was the obvious one.> <What happened when
it was tried: the specific failure, with the number or symptom.> <What replaced
it, and what that cost.>
```

Then list what was deliberately not built. It reads as judgment, not omission.

Every number and API name in this section comes from the source, verified. Docs
go stale; a wrong number in the one section a reviewer reads closely is the
costliest possible error.

## 10: roadmap

Framed as scope control, not as a wish list. "Deferred until X is proven" reads
as engineering judgment; an unordered pile of features reads as an unfinished
project.

## 11: about

Who built it, one line on availability, and an explicit statement that the source
is private with an offer to walk through it. That offer is the point: it turns a
closed repo from a gap into an invitation.

```markdown
## About

Built by <Name>. <One line of relevant context.>

The source for <AppName> is private. Happy to walk through the code and the
decisions behind it in an interview.
```
