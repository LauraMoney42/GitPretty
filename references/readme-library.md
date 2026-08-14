# README shape: library, package, CLI, or MCP server

For anything a reader arrives wanting to **install and use**. Packages, CLIs,
SDKs, MCP servers, plugins, GitHub Actions.

The reader's question is "will this solve my problem, and how fast can I find
out." They are usually comparing two or three options in adjacent tabs. Every
line above the install command is a line they read while still deciding whether
to close the tab.

## The rule that matters

**The install command goes above the fold.** A hero GIF that pushes
`pip install thing` below the fold costs adoption, because the reader came to
try it, not to be impressed. If there is media, keep it to one small image or
terminal recording, above or beside the install, never a full-width screenshot
gallery.

This is the opposite of a showcase or portfolio README, and getting it backwards
is the most common way a good library reads as a toy.

## Section order

| # | Section | Job |
|---|---------|-----|
| 1 | Name and one-line description | What it is, in the reader's vocabulary |
| 2 | Badges | Version, CI, license, downloads |
| 3 | The pitch | 2 to 3 sentences, including the number that makes it worth it |
| 4 | Install | One command |
| 5 | Quickstart | The smallest complete working example |
| 6 | Why / when to use it | Honest scope, including when not to |
| 7 | Usage | The 3 to 5 things people actually do |
| 8 | API reference | Table or link to docs |
| 9 | How it works | Optional, but this is where a technical reader lingers |
| 10 | Contributing, license | Short |

## 1 to 3: header

Keep it centered only if there is a logo. Otherwise plain markdown headers read
faster and survive on npm and PyPI, which strip most HTML.

```markdown
# <name>

<One line. What it does and for whom, in the words someone would search.>

[![PyPI](https://img.shields.io/pypi/v/<pkg>?style=flat-square)](https://pypi.org/project/<pkg>/)
[![CI](https://img.shields.io/github/actions/workflow/status/<owner>/<repo>/ci.yml?style=flat-square)](https://github.com/<owner>/<repo>/actions)
[![License](https://img.shields.io/badge/license-MIT-4CCC93?style=flat-square)](LICENSE)
```

Only add a CI badge if CI actually runs and passes. A red or stale badge is worse
than none, because it is a live signal that the project is unmaintained.

The pitch is where a concrete number belongs, if one exists: "60 to 95% fewer
tokens on JSON, same answers" does more work than any adjective. Verify it
against a benchmark in the repo before printing it.

## 4 to 5: install and quickstart

```markdown
## Install

​```bash
pip install <pkg>
​```

## Quickstart

​```python
from <pkg> import <thing>

result = <thing>(<realistic input>)
print(result)   # <actual output, copied from a real run>
​```
```

The quickstart must be **complete and runnable**. No `...`, no undefined
variables, no imports left implicit. Actually run it and paste the real output.
A quickstart that fails on line one is the fastest way to lose a user, and it is
the single most common defect in library READMEs.

Show one realistic use, not the trivial one. `add(2, 2)` proves nothing.

## 6: why and when

Two short lists. The second one is what builds trust:

```markdown
## When to use it

- <situation where this is the right tool>
- <another>

## When not to

- <situation where something else is better, named>
```

Naming the tool that beats yours in some case reads as confidence, not weakness,
and it stops people arriving with the wrong expectations and leaving annoyed.

## 7 to 8: usage and API

Lead with the 3 to 5 things people actually do, each as a titled block with a
runnable snippet. Then a compact reference table:

```markdown
| Function | Signature | Does |
|---|---|---|
| `<name>` | `(<args>) -> <ret>` | <one line> |
```

Generate this from the source rather than by hand, or it drifts within two
releases. If the API is larger than about fifteen entries, link to real docs
instead and keep the table to the common path.

## 9: how it works

Optional, and often the section that converts a curious reader into a
contributor. A mermaid diagram plus two or three decisions with reasoning. See
the mermaid gotchas in the skill body.

Keep it honest about limits. "Falls back to the slow path when X" is more useful
than a claim of universal performance, and the reader will find out anyway.

## 10: contributing and license

Three lines is enough. Link `CONTRIBUTING.md` if it exists, name the license,
and say how to run the tests, since that is the first thing a contributor needs.

```markdown
## Contributing

Issues and PRs welcome. `<test command>` runs the suite.

## License

<MIT / Apache 2.0 / ...>. See [LICENSE](LICENSE).
```

A public repo with no license file is legally "all rights reserved," which means
nobody can use it. If the intent is for people to use it, the license is not
optional furniture. See `repo-polish.md`.
