---
name: gitpretty
description: Build a public "showcase" repo that proves a private app is real, without publishing its source. Produces AppName-public with a hero GIF, captioned screenshots, a mermaid architecture diagram, and honest engineering decisions, then ships it with gh. Use this whenever the user wants to show off, demo, publish, or share a project they cannot open-source: "make a public repo for my app", "portfolio repo", "showcase repo", "landing page for my project", "something to send a recruiter or hiring manager", "prove I built this without giving away the code", "write a README that sells this app", or when they mention a `-public` repo. Also use it when they ask for a demo GIF or screenshot table for a README, or an architecture diagram for a project page.
---

# GitPretty

Build a public repo a hiring manager can skim in two minutes that proves the app
is real and that the author can explain how it works, without publishing the
source. The private repo stays private. This one is a landing page.

Budget about 45 minutes once screenshots exist. Most of that is media prep and
verification, not writing.

## The shape of the job

Reviewers spend two minutes here. They look at the hero GIF, skim the
screenshots, and read exactly one prose section closely: architecture. Everything
below optimizes for that reality. Front-load the proof, back-load the
engineering, and make every checkable claim true, because the one section they
read carefully is the one where a wrong number costs the most.

## Step 0: is publishing allowed?

Skip only if the project is entirely the user's own. For anything built for an
employer or client, the screenshots, architecture, and product decisions are
usually theirs. Ask the user directly whether they have permission, and if the
answer is unclear, say so rather than proceeding. A showcase repo that causes
trouble is worse than no showcase repo.

Three middle grounds when the answer is no or uncertain:

- Describe the problem shape and their decisions without naming the employer,
  showing their UI, or reproducing their data model
- Rebuild a small standalone demo of the interesting technique and publish that,
  which is theirs outright
- Keep the repo private and share the link directly with interviewers

## Step 1: gather source material

Ask for or locate:

- The private repo path, so architecture can be written from the code
- Existing screenshots (App Store assets, simulator captures, browser grabs)
- A screen recording, if one exists
- Current status: shipped, in review, internal only, or not released

Nothing new needs to be shot. Reuse what exists.

## Step 2: build the media

Layout:

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

All ffmpeg and sips commands live in `references/media.md`. Read that file before
encoding anything. It covers the contact sheet, the mp4 and GIF encodes, the
no-recording slideshow path, and the frame-normalization step that GIF builds
silently need.

Two things matter more than the exact flags:

**Find a clean segment before encoding.** Recordings almost always open on a
permission alert and end on failed-thumbnail placeholder cards. Build a contact
sheet, look at it, and pick the good stretch first.

**A relative `.mp4` path in a GitHub README does not produce a player.** The GIF
is the visible hero; the mp4 is a link underneath it. Do not fight this:

```html
<p align="center">
  <img src="media/app-demo.gif" width="270" alt="...">
</p>
<p align="center"><a href="media/app-demo.mp4"><b>▶ Watch the full 24-second demo</b></a></p>
```

Keep the GIF under about 3 MB, since it loads on every page view, and the mp4
under about 2 MB.

## Step 3: verify what is actually in each file before captioning it

This is the single most likely error in the whole process, and it is the kind a
reviewer notices and the author does not. Timestamped filenames
(`Simulator Screenshot - ... 16.48.50.png`) say nothing about content, and two
adjacent captures are often the same screen at different scroll positions.

Contact sheet the **final** screenshot set, in filename order, and actually read
it before writing a single caption. The command is in `references/media.md`.

If two screenshots are near-duplicates, cut one or write the caption around the
part that differs.

## Step 4: write the README

Use the section order and markup in `references/readme-template.md`. Read that
file when it is time to write.

The order is: title and tagline, attribution, badges, status line, demo, the
problem, the app (screenshot tables), the hard constraint, architecture,
roadmap, about.

Two sections carry most of the weight:

**The hard constraint.** Every app has one thing it could not do. Explaining
that limit, and how the UI handles it honestly, is the most credible section on
the page. It is also the one a reviewer cannot get from a screenshot.

**Architecture.** This is where the reviewer actually reads. It needs a mermaid
diagram, a service responsibility table with one line per service, and two to
four decisions written as: what was done, what the obvious alternative was, and
what broke when it was tried. Concrete beats impressive. A real bug that got
fixed is worth more than any adjective. Include what was deliberately not built,
which reads as judgment rather than omission.

### Write from the code, not from the docs

Pull every number and API name out of the source before it goes on the page.
Project overview docs go stale quietly. In one real pass, an architecture doc was
five months behind on a retention window: it said 24 hours, `Constants.swift`
said 35 days. Publishing the doc's number would have put a confident, checkable,
wrong claim in the one section a reviewer reads closely.

The best material is usually already in the code as a comment explaining why
something changed. Grep for the framework names and read what past-them wrote.

### Mermaid gotchas, all hit for real

These render fine locally and only break on GitHub, so they are worth knowing
before drawing rather than after:

- `<br/>` and `<i>` inside node labels render as run-together text. Keep node
  names plain and put descriptions in a table underneath
- `direction LR` inside a subgraph is ignored when the subgraph has external
  edges. A `flowchart TD` of stacked subgraphs becomes an unreadably tall
  column. Use `flowchart LR` at the top level so layers become columns
- A subgraph containing a single node adds a rank for no reason and bends the
  layout into a diagonal staircase. Make it a bare node instead
- GitHub caches the rendered diagram. After pushing a fix, a plain reload can
  still show the old picture. Force-reload before concluding the fix failed

Working shape:

```
flowchart LR
    subgraph V["Views"]
        Deck[Sweep deck]
    end
    subgraph S["Services, sole owner of system access"]
        Lib[PhotoLibrary]
    end
    subgraph F["Platform frameworks"]
        PK[PhotoKit]
    end
    Deck --> Lib
    Lib --> PK

    style V fill:#635BFF22,stroke:#635BFF
    style S fill:#4CCC9322,stroke:#4CCC93
    style F fill:#88888822,stroke:#888888
```

The `22` suffix on each hex is alpha, giving tinted fills that stay readable in
both light and dark themes. Pull the colors from the app's own palette so the
page looks like the product.

## Step 5: what must not ship

Check for these before the first commit, since a public repo's history keeps
whatever lands in it:

- Source, even snippets long enough to reconstruct anything
- Build commands, signing setup, `project.yml`, team IDs, bundle identifiers
- Internal hostnames, dashboard links, ticket numbers, coworker names
- Anything copied verbatim from the private repo's overview doc, which contains
  file trees and build steps. Write *from* it, do not copy it
- Screenshots with real personal data. Use a synthetic dataset and say so in the
  README. For a health, finance, or messaging app this is not optional

## Step 6: ship it

```bash
mkdir -p AppName-public/{media,screenshots}
cd AppName-public
printf '*.png binary\n*.gif binary\n*.mp4 binary\n' > .gitattributes
git init -b main && git add -A && git commit -m "Add AppName showcase page"
```

Prove no source leaked before the push:

```bash
git ls-files | grep -Ev '\.(png|gif|mp4|md)$|\.gitattributes'
```

That prints nothing if the repo is clean. If it prints anything, look at each
file before continuing.

Creating a public repo publishes it, so confirm with the user before running
this rather than after:

```bash
gh repo create AppName-public --public --source=. --remote=origin --push \
  --description "AppName. One line. Demo, screenshots and architecture walkthrough."
```

Then open the live page and actually look at it. Every mermaid bug listed above
rendered correctly as local markdown and only appeared on GitHub. Scroll the
whole README: hero, every screenshot, the diagram, the tables, the end.

## Checklist

Work through this at the end. Each line is something that has actually gone
wrong before.

- [ ] Confirmed the user is allowed to publish it
- [ ] Contact sheeted the recording, picked a segment with no permission alerts
      or placeholder cards
- [ ] mp4 under 2 MB, GIF under 3 MB, or a slideshow GIF built from stills
- [ ] Screenshots downsized and renamed for what they show
- [ ] Contact sheeted the final set and confirmed every caption matches its file
- [ ] Every number and API name verified against the source, not the docs
- [ ] README has all eleven parts in order
- [ ] Mermaid: `flowchart LR`, plain node labels, no single-node subgraphs,
      descriptions in a table
- [ ] README states the source is private and offers a walkthrough
- [ ] `git ls-files` shows no code
- [ ] User confirmed, then `gh repo create --public --source=. --push`
- [ ] Loaded the live page, force-reloaded, scrolled the entire README
- [ ] Noted the follow-up: swap the status line for the store link on approval

## Reference files

- `references/media.md`: every ffmpeg and sips command. Contact sheets, mp4 and
  GIF encodes, the slideshow path for when there is no recording, and caption
  verification. Read before encoding.
- `references/readme-template.md`: the section-by-section README skeleton with
  working HTML for the hero, badges, and screenshot tables. Read before writing.
