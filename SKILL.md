---
name: gitpretty
description: Make a git repo look like someone is proud of it. Writes the README, builds a hero GIF or screenshot set, draws a mermaid architecture diagram, and fills in the GitHub furniture (description, topics, license, social preview). Handles four repo shapes: an installable library or CLI, an open-source app, a personal or portfolio project, and a private app that needs a public showcase page with no source. Use this whenever the user wants a repo to look better or read better: "prettify my repo", "write a README for this", "my repo looks bare", "clean up my GitHub", "add a demo GIF", "make an architecture diagram for the README", "add badges", "something I can send a recruiter", "showcase repo", "portfolio repo", or any `-public` repo. Also use it when they ask to audit or survey several repos at once for missing READMEs, descriptions, or topics.
---

# GitPretty

Make a repo look like someone is proud of it.

A repo is read in a fixed order, and prettifying it means making each step of
that order do its job:

1. **The GitHub card**: name, description, topics. This is all a browser or a
   search result shows. An empty description is the single most common reason a
   real project reads as abandoned
2. **The hero**: the first image on the page, before any scrolling
3. **The first screen of README**: what it is, whether it works, how to start
4. **One prose section, read closely**: usually architecture, sometimes usage

Everything below serves those four. Budget 20 minutes for a light pass on an
existing repo, about 45 minutes when media has to be built from scratch.

## Step 1: pick the mode

Ask, or infer from what the user pointed at.

| Mode | When | Where to go |
|---|---|---|
| **Audit** | Several repos at once, "clean up my GitHub" | Run `scripts/audit.sh`, then pick targets with the user |
| **Prettify** | One existing repo, source is public | Step 2, then the matching README recipe |
| **Showcase** | Private app, source must stay private | Step 2, but read `references/readme-showcase.md` and take the permission gate seriously |

Audit mode is a survey, not a change. It reports which repos have no
description, no topics, no license, or a thin README, so the user can choose
where the effort goes. Do not start editing repos off the back of an audit
without the user picking them.

## Step 2: pick the README shape

The section order is not universal. It depends on why someone landed on the
repo, and getting this wrong is the most common way a decent README still fails.

| Reader arrives wanting to... | Shape | Reference |
|---|---|---|
| Install and use it | Library, package, CLI, MCP server | `references/readme-library.md` |
| Run it, or see what it does | App or tool, source visible | `references/readme-app.md` |
| Judge whether you can build | Personal or portfolio project | `references/readme-app.md`, portfolio variant |
| Believe an app is real without seeing code | Private app, public landing page | `references/readme-showcase.md` |

The split that matters most: **someone who came to install something wants the
quickstart above the fold**, and a hero GIF that pushes `pip install` below the
fold actively costs adoption. **Someone who came to judge** wants proof first,
because they will not scroll unless the first screen convinces them.

Read the matching reference file before writing. Each one carries a section
order, the markup that renders correctly on GitHub, and notes on what earns its
place.

## Step 3: read the repo before writing about it

Pull every number, command, and API name out of the source. Docs go stale
quietly. In one real pass, an architecture doc was five months behind on a
retention window: it said 24 hours, `Constants.swift` said 35 days. Publishing
the doc's number would have put a confident, checkable, wrong claim in the one
section a reviewer reads closely.

Worth reading before writing:

- The entry point, to describe what actually happens on start
- Config and constants files, for every number that will appear on the page
- Existing tests, which document the real interface better than most READMEs
- Comments explaining why something changed. Grep for framework names and read
  what past-them wrote; this is usually the best material on the page
- `package.json`, `Cargo.toml`, `pyproject.toml`, or equivalent, for the real
  install name and version

If the repo already has a README, keep what is accurate. Rewriting a working
README from scratch loses institutional knowledge and annoys the person who
wrote it.

## Step 4: media

Optional for a library, close to mandatory for anything with a UI. A repo with a
screenshot reads as finished; the same repo without one reads as a work in
progress, even when the code is identical.

All ffmpeg and sips commands live in `references/media.md`. Read that file
before encoding. It covers contact sheets, the mp4 and GIF encodes, the
slideshow path for when there is no recording, and caption verification.

**Encode at 2x the width you will display it at.** GitHub sizes the image from
the `width=` attribute and every reader is on a Retina screen, so a 540px file
shown at `width="270"` is crisp where a 270px file is soft. Never upscale past
the source, and always work from the original recording rather than an
already-downsized copy, since resizes compound and nothing recovers what the
first one threw away.

Four things that matter more than the flags:

**A CLI deserves a terminal GIF.** Record an actual session with
[`vhs`](https://github.com/charmbracelet/vhs) or `asciinema`. A terminal
recording of a tool doing its job is the highest-value-per-byte asset a library
README can have.

**A relative `.mp4` in a GitHub README does not produce a player.** The GIF is
the visible hero; the mp4 is a link underneath it. Do not fight this:

```html
<p align="center">
  <img src="media/demo.gif" width="270" alt="...">
</p>
<p align="center"><a href="media/demo.mp4"><b>▶ Watch the full 24-second demo</b></a></p>
```

**Two-pass palette, `bayer_scale=5`, and `diff_mode=rectangle`.** Those three
give a GIF that is sharper, smoother, and smaller than the usual defaults at the
same time. Error-diffusion dithering (`sierra2_4a`, `floyd_steinberg`) is the
trap: it looks good on one still and is nine times larger across frames, because
the noise changes everywhere every frame and inter-frame compression stops
working.

**Verify what is in each file before captioning it.** Timestamped filenames
(`Simulator Screenshot - ... 16.48.50.png`) say nothing about content, and two
adjacent captures are often the same screen at different scroll positions.
Contact sheet the final set and read it. A caption on the wrong screenshot is
the kind of error a reviewer catches and the author never does.

Keep the GIF under about 3 MB, since it loads on every page view. The mp4 is
only fetched when someone clicks it, so it can afford real quality: cap the
width at 1280, use `-crf 20`, and budget up to 5 MB. If a sharp GIF will not fit
the budget, cut duration before resolution, and see the video-upload escape
hatch at the end of `references/media.md`.

## Step 5: the architecture diagram

Worth adding whenever the repo has more than one moving part. It is the section
a technical reader actually reads, and a diagram is faster to trust than three
paragraphs claiming the same thing.

Three parts: a mermaid diagram, a table with one line per component, and two to
four decisions written as what was done, what the obvious alternative was, and
what broke when it was tried. Concrete beats impressive; a real bug that got
fixed is worth more than any adjective. Include what was deliberately not built,
which reads as judgment rather than omission.

### Mermaid gotchas, all hit for real

These render correctly in a local markdown preview and only break on GitHub,
which is why they are worth knowing before drawing rather than after:

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
    subgraph V["Interface"]
        A[CLI]
    end
    subgraph S["Core, sole owner of state"]
        B[Scheduler]
    end
    subgraph F["Platform"]
        C[SQLite]
    end
    A --> B
    B --> C

    style V fill:#635BFF22,stroke:#635BFF
    style S fill:#4CCC9322,stroke:#4CCC93
    style F fill:#88888822,stroke:#888888
```

The `22` suffix on each hex is alpha, giving tinted fills that stay readable in
both light and dark themes. Pull the colors from the project's own palette so
the page looks like the product.

## Step 6: the GitHub furniture

The README is not the whole repo. `references/repo-polish.md` covers the
surfaces outside it: description and topics, license, social preview image,
release tags, and the About panel. Read it before finishing.

The highest-value item by far is the repo description, because it is the only
text that follows the repo into search results, profile pages, and every link
someone shares. Setting one takes ten seconds:

```bash
gh repo edit OWNER/REPO --description "One line: what it is and who it is for."
```

## Step 7: what must not ship

Check before the first commit, since a public repo's history keeps whatever
lands in it. This matters most in showcase mode, but a secret committed to any
repo is a secret published:

- Credentials, tokens, `.env` files, signing keys, or anything matching
  `api[_-]?key`. Grep before pushing
- Internal hostnames, dashboard links, ticket numbers, coworker names
- Screenshots containing real personal data. Use a synthetic dataset and say so
  in the README. For a health, finance, or messaging app this is not optional

In showcase mode, additionally: no source at all, no build commands, no signing
setup, no team IDs or bundle identifiers, and nothing copied verbatim from a
private overview doc, since those contain file trees and build steps. Write
*from* it, do not copy it. Prove the repo is clean before pushing:

```bash
git ls-files | grep -Ev '\.(png|gif|mp4|md)$|\.gitattributes'
```

That prints nothing if only media and markdown are staged.

## Step 8: ship and look at it

Committing to an existing repo is the user's call, and creating a public repo
publishes it, so confirm before running either rather than after.

For a new showcase repo:

```bash
gh repo create AppName-public --public --source=. --remote=origin --push \
  --description "AppName. One line. Demo, screenshots and architecture walkthrough."
```

Then open the live page and actually look at it. Every mermaid bug listed above
rendered correctly as local markdown and only appeared on GitHub. Scroll the
whole README: hero, every image, the diagram, the tables, the end.

## Checklist

Each line is something that has actually gone wrong before.

- [ ] Mode picked, and in showcase mode, permission to publish confirmed
- [ ] README shape matches why a reader arrives
- [ ] Every number and API name verified against source, not docs
- [ ] Install or quickstart command copy-pasteable and actually tried
- [ ] Media encoded at 2x display width, never upscaled past the source
- [ ] Media under budget: GIF 3 MB, mp4 5 MB, images 400 KB each
- [ ] Contact sheeted the final image set, every caption matches its file
- [ ] Mermaid: `flowchart LR`, plain node labels, no single-node subgraphs
- [ ] No secrets, no internal names, no real personal data
- [ ] Repo description and topics set
- [ ] User confirmed, then committed and pushed
- [ ] Loaded the live page, force-reloaded, scrolled the entire README

## Reference files

- `references/media.md`: every ffmpeg and sips command. Contact sheets, mp4 and
  GIF encodes, terminal recordings, the slideshow path for when there is no
  recording, and caption verification. Read before encoding.
- `references/readme-library.md`: README shape for anything installable.
  Packages, CLIs, MCP servers.
- `references/readme-app.md`: README shape for an app or tool with visible
  source, plus the portfolio-project variant.
- `references/readme-showcase.md`: README shape for a private app's public
  landing page, plus the permission gate.
- `references/repo-polish.md`: everything outside the README. Description,
  topics, license, social preview, releases, About panel.
- `scripts/audit.sh`: survey many repos at once and report what each is missing.
