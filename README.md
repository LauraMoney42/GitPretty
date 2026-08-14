<h1 align="center">GitPretty</h1>

<p align="center"><i>A Claude Code skill that turns a private app into a public repo a hiring manager will actually read.</i></p>

<p align="center">
  Built by <a href="https://github.com/LauraMoney42"><b>Laura Money</b></a>
</p>

<p align="center">
  <img alt="Type: Claude Code skill" src="https://img.shields.io/badge/type-Claude%20Code%20skill-635BFF?style=flat-square">
  <img alt="Install: copy one folder" src="https://img.shields.io/badge/install-one%20folder-4CCC93?style=flat-square">
  <img alt="Dependencies: ffmpeg, gh" src="https://img.shields.io/badge/deps-ffmpeg%20%2B%20gh-FFBE4F?style=flat-square">
  <img alt="Time: ~45 minutes" src="https://img.shields.io/badge/time-~45%20min-1c1c1e?style=flat-square">
</p>

---

<p align="center">
  <img src="media/gitpretty-demo.gif" width="270" alt="Five screens from a showcase repo built with GitPretty: onboarding, love, nope, keep, and filters">
</p>

<p align="center">
  <a href="https://github.com/LauraMoney42/PhotoHoarder-public"><b>See the full worked example: PhotoHoarder-public</b></a><br>
  <sub>Those five screens are the screenshot set from a real showcase repo built this way.</sub>
</p>

---

## The problem

You built something good and you cannot show the code. It is under NDA, it is a
client's, or it is a product you intend to sell. So the work sits in a private
repo where nobody can see it, and your portfolio says "ask me about it."

The usual fix is a public repo with a thin README, which reads as an abandoned
side project. What a reviewer actually needs is proof the thing is real and
evidence you can explain how it works. That is a specific document, and it has a
specific shape.

## What it does

Run it against a private project and it walks the whole job:

1. **Permission gate.** Asks whether you are allowed to publish, and offers three
   middle grounds if the answer is unclear
2. **Media.** Builds a hero GIF and a linked mp4 from an existing screen
   recording, or a slideshow GIF from stills when there is no recording
3. **Verification.** Contact sheets your screenshots so no caption ends up
   describing the wrong screen
4. **README.** Eleven sections in a fixed order, front-loading the proof and
   back-loading the engineering
5. **Ship.** Leak check, then `gh repo create`, then a pass over the live page

The output is an `AppName-public` repo containing media, screenshots, and a
README. No source, ever.

## Why the README order is fixed

A reviewer spends about two minutes here. They look at the GIF, skim the
screenshots, and read exactly one prose section closely: architecture. So the
demo goes near the top, and the engineering goes after they are already
convinced the app exists.

Two sections carry most of the weight, and both are ones a reviewer cannot get
from a screenshot:

**The hard constraint.** Every app has one thing it could not do. Naming that
limit, and showing how the UI handles it honestly, is the most credible thing on
the page, because it is the easiest thing to have hidden.

**Architecture.** A mermaid diagram, a service responsibility table, and two to
four decisions written as: what you did, what the obvious alternative was, and
what broke when you tried it. A real bug you fixed is worth more than any
adjective.

## What is actually in here

| File | What it holds |
|---|---|
| `SKILL.md` | The workflow, the permission gate, the mermaid gotchas, and the ship checklist |
| `references/media.md` | Every ffmpeg and sips command, with the failure modes that make them necessary |
| `references/readme-template.md` | The eleven-section skeleton, with markup that renders correctly on GitHub |

## The gotchas it encodes

This started as notes taken while building a showcase repo by hand. Everything
below is something that actually went wrong, which is the reason the skill exists
rather than a prompt saying "write a nice README":

- **Timestamped filenames lie.** `Simulator Screenshot - ... 16.48.50.png` tells
  you nothing, and two adjacent captures are often the same screen at different
  scroll positions. Contact sheet the final set before writing captions. A
  caption on the wrong screenshot is the kind of error a reviewer catches and you
  never do
- **Docs go stale, code does not.** In one pass, an architecture doc was five
  months behind on a retention window: it said 24 hours, `Constants.swift` said
  35 days. Every number on the page gets verified against source
- **A relative `.mp4` in a GitHub README does not produce a player.** The GIF is
  the visible hero; the mp4 is a link underneath
- **Mermaid breaks only on GitHub.** `<br/>` in node labels runs text together,
  `direction LR` inside a subgraph is ignored when the subgraph has external
  edges, and a single-node subgraph bends the layout into a staircase. All three
  render fine locally
- **GitHub caches rendered diagrams.** Force-reload before concluding your fix
  did not work
- **Feeding a glob of stills straight into `paletteuse` fails** on ffmpeg 8.x
  with "Internal bug, should not have happened." Route through an intermediate
  mp4

## Install

```bash
git clone https://github.com/LauraMoney42/GitPretty.git ~/.claude/skills/gitpretty
```

Then start a new Claude Code session and say what you want:

```
build a public showcase repo for my app in ~/Documents/GIT/MyApp
```

The skill triggers on its own for showcase repos, portfolio repos, and "something
I can send a recruiter." You can also invoke it by name with `/gitpretty`.

Needs [`ffmpeg`](https://ffmpeg.org) for media and [`gh`](https://cli.github.com)
for the push. `sips` ships with macOS.

## About

Built by Laura Money, from notes taken while shipping
[PhotoHoarder-public](https://github.com/LauraMoney42/PhotoHoarder-public).

The screens in the demo above are that repo's screenshot set, run back through
the skill's own slideshow recipe.
