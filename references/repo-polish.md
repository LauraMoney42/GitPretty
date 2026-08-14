# Everything outside the README

The README is what someone reads after they click. This file is about
everything that decides whether they click, plus the furniture that makes a repo
read as maintained.

## Contents

- [1. Description and topics](#1-description-and-topics)
- [2. License](#2-license)
- [3. Social preview image](#3-social-preview-image)
- [4. The About panel](#4-the-about-panel)
- [5. Releases and tags](#5-releases-and-tags)
- [6. Signals of abandonment](#6-signals-of-abandonment)
- [7. Repo hygiene files](#7-repo-hygiene-files)

## 1. Description and topics

The highest value per second of work in this entire skill.

The description is the only text that follows a repo everywhere: search results,
profile pages, org listings, and the preview card on every link someone shares.
A repo with an empty description is invisible in search and reads as abandoned
even when it is not.

```bash
gh repo edit OWNER/REPO \
  --description "One line: what it is and who it is for." \
  --add-topic <topic> --add-topic <topic> --add-topic <topic>
```

Writing a good one:

- Say what it **is** before what it does. "CLI that ..." or "iOS app for ..."
  orients the reader in three words
- Include the words someone would search for, since this text is indexed
- Skip the repo name, which is already on screen
- One sentence, no trailing period needed, under about 120 characters so it does
  not truncate in listings

Topics drive GitHub's own discovery pages. Three to six is right: the language,
the domain, and the platform or framework. Use existing popular topics rather
than inventing new ones, since an invented topic has no page to be found on.

## 2. License

A public repo with no `LICENSE` file is legally "all rights reserved." Nobody may
copy, modify, or use it, which is the opposite of what most public repos intend.
It also blocks any company from touching the code, since their legal review will
stop at the missing file.

Pick based on intent, and ask rather than assuming, since this is the user's call
and not a stylistic one:

| Intent | License |
|---|---|
| Maximum adoption, no conditions | MIT |
| Same, plus explicit patent grant | Apache 2.0 |
| Derivatives must stay open | GPL-3.0 |
| Public code, but no reuse permitted | No license, stated deliberately in the README |

That last row is legitimate for a showcase or portfolio repo. If reuse is not
intended, say so in the README rather than leaving readers to infer it from an
absent file.

```bash
gh repo view OWNER/REPO --json licenseInfo    # check what is there now
```

Add one by committing a `LICENSE` file, or through GitHub's "Add file" flow,
which offers templates with the year and name prefilled.

## 3. Social preview image

The image that renders when a repo link is pasted into Slack, LinkedIn, X, or
iMessage. Without one, the card shows a generic grey GitHub avatar, which makes a
shared link look like nothing.

This matters most for exactly the repos a job seeker shares deliberately.

- Size: **1280x640** pixels
- Keep text large and centered, since the card renders small
- Set it at Settings → General → Social preview → Upload an image

A workable source is the hero GIF's best frame, padded to 1280x640:

```bash
ffmpeg -y -i media/demo.gif -vf "select=eq(n\,12),scale=-1:560,pad=1280:640:(ow-iw)/2:(oh-ih)/2:0x0d1117" \
  -frames:v 1 social-preview.png
```

Keep `social-preview.png` out of the repo, or in a `.github/` folder, since it is
an upload rather than page content.

## 4. The About panel

The right-hand sidebar on the repo page. Beyond description and topics:

- **Website**: point it at the live app, the docs, or the App Store listing. An
  unused field here is a wasted click for anyone trying to see the thing running
- **Releases, Packages, Deployments**: hide the sections that are empty, since an
  empty "Releases" panel reads as a project that never shipped

## 5. Releases and tags

For anything installable, a tagged release is the difference between "someone
maintains this" and "here is a pile of code." It also gives users something
stable to pin to.

```bash
git tag -a v0.1.0 -m "First release" && git push origin v0.1.0
gh release create v0.1.0 --title "v0.1.0" --notes "<what changed>"
```

Not needed for a showcase page or a portfolio project, where the repo is the
artifact and there is nothing to install.

## 6. Signals of abandonment

Worth scanning for, because each one quietly tells a visitor the project is dead:

- A **red or stale CI badge**. Fix the build or remove the badge; a broken badge
  is worse than none
- **Open issues with no reply for a year** on a repo presented as active
- A README that says "coming soon" with no date, or a status line that has
  outlived the thing it described
- **Commits only from the initial import**, with no follow-up, on a repo claiming
  active development
- A default branch called `master` on a repo otherwise presented as current

If a project genuinely is finished or parked, saying so is strictly better than
letting a reader guess:

```markdown
> **Status:** Archived. Built <year>, kept here as reference. Not maintained.
```

## 7. Repo hygiene files

Small, quick, and each one removes a visible rough edge:

| File | Why |
|---|---|
| `.gitignore` | Committed `.DS_Store` or `node_modules` is the loudest possible signal of carelessness |
| `.gitattributes` | `*.png binary` etc. keeps git from trying to diff media |
| `.env.example` | Lets someone run the app; ship this and never the real `.env` |
| `CONTRIBUTING.md` | Only if contributions are actually wanted |

Check for the embarrassing ones already tracked:

```bash
git ls-files | grep -E '\.DS_Store|node_modules/|\.env$|\.pyc$'
```

If that prints anything, remove it from tracking (`git rm --cached <file>`) and
add it to `.gitignore`. Note that this leaves the file in history; for a
committed secret, rotate the secret, since removing it from the tip of the tree
does not unpublish it.
