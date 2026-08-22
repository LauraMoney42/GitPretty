# Media recipes

Every command needed to turn a screen recording and some screenshots into a
sharp hero GIF, a linked mp4, and a verified screenshot set. Requires `ffmpeg`
(`brew install ffmpeg`); `sips` ships with macOS.

The defaults here favor **clarity first, then size**. A blurry demo makes a
polished app look cheap, and the whole point of the page is that the work looks
like someone cared.

## Contents

- [1. Check the source before encoding anything](#1-check-the-source-before-encoding-anything)
- [2. Contact sheet the recording](#2-contact-sheet-the-recording)
- [3. Encode the mp4](#3-encode-the-mp4)
- [4. Encode the hero GIF](#4-encode-the-hero-gif)
- [5. No recording? Slideshow GIF from stills](#5-no-recording-slideshow-gif-from-stills)
- [6. Screenshots](#6-screenshots)
- [7. Verify captions against the actual files](#7-verify-captions-against-the-actual-files)
- [8. Size and sanity checks](#8-size-and-sanity-checks)
- [9. When high res will not fit](#9-when-high-res-will-not-fit)

## 1. Check the source before encoding anything

Three rules decide how sharp the result can possibly be. Getting them right is
worth more than any encoder flag.

```bash
ffprobe -v error -select_streams v:0 -show_entries stream=width,height,r_frame_rate,nb_frames \
  -of default=noprint_wrappers=1 "recording.mov"
```

**Encode at 2x the width you will display it at.** GitHub renders the image at
whatever `width=` says in the HTML, and everyone reading is on a Retina or HiDPI
screen. A file 270px wide shown at `width="270"` is soft; a file 540px wide shown
at `width="270"` is crisp. The display attribute controls layout, the file
supplies the pixels.

| Displayed at | Encode at | Typical use |
|---|---|---|
| `width="270"` | 540 or the phone's native width | Phone screencast |
| `width="640"` | 1280 | Desktop app or web UI |
| `width="230"` (in a table) | 460 to 900 | Screenshot cells |

**Never upscale past the source.** Output width above the source width adds bytes
and zero detail, and on flat UI it looks worse than the original because the
scaler invents soft edges. If `ffprobe` says the recording is 414 wide, 414 is
the ceiling.

**Work from the original recording, never from an already-downsized asset.**
Every resize is lossy and they compound. This skill's own demo GIF is capped at
414px because it was built from screenshots that had already been through
`sips -Z 900`, and no flag can recover what that threw away. Keep the originals,
downsize once, at the end.

To capture at native resolution in the first place: on macOS, Simulator's
File > Record Screen and QuickTime's screen recording both write at device
resolution. Do not shrink the window to make the file smaller.

## 2. Contact sheet the recording

Do this before encoding anything. Recordings almost always open on a permission
alert and end on failed-thumbnail placeholder cards, and the only way to find the
clean stretch is to look at the whole thing at once.

```bash
# one frame every 2s, left to right, top row then bottom
ffmpeg -i "recording.mov" -vf "fps=1/2,scale=170:-1,tile=10x2" -frames:v 1 sheet.png
```

Open `sheet.png` and read it. Frame N in the grid is at roughly `N * 2` seconds,
which gives the `-ss` start offset for the encodes below.

## 3. Encode the mp4

The mp4 is linked rather than embedded, so it is not paid for on every page
view. That makes it the place to keep real quality: this is the file someone
opens when they actually want to watch the thing work.

```bash
ffmpeg -ss 3.5 -t 24 -i "recording.mov" \
  -vf "scale='min(1280,iw)':-2:flags=lanczos" \
  -c:v libx264 -preset slow -crf 20 -pix_fmt yuv420p -movflags +faststart -an \
  media/app-demo.mp4
```

- `scale='min(1280,iw)':-2` caps the width at 1280 but **never upscales**, since
  `iw` wins when the source is narrower. `-2` forces an even height, which h264
  requires
- `flags=lanczos` is a sharper scaler than the default bilinear, and costs
  nothing
- `-ss` before `-i` seeks fast; `-t` is duration, not end time
- `-an` drops audio, which a screencast does not need and which costs bytes
- `+faststart` moves the index to the front so playback can start before the
  file has fully downloaded

### CRF is the quality dial

Lower is better and bigger. Measured on a 24-second 620x1348 phone screencast:

| CRF | Size | Looks like |
|---|---|---|
| 28 | 1.4 MB | Fine at thumbnail size, soft on text |
| 23 | 2.0 MB | Good default if size is tight |
| **20** | **2.5 MB** | **Crisp text, the recommended default** |
| 18 | 2.9 MB | Visually lossless, hard to justify for a demo |

Those absolute numbers came from re-encoding an already-compressed clip, so a
pristine recording will land differently; the ratios between rows are what
transfer. Re-measure with `du -h` and pick the row that fits the budget.

Use `-preset veryslow` instead of `slow` for another 5 to 10% off at the same
quality, at the cost of a much longer encode. Worth it for a file you will ship
once.

## 4. Encode the hero GIF

The GIF loads on every single page view, including on phones, so it is the one
asset where size genuinely constrains quality. Pick the most visually
interesting 10 to 15 seconds, not the beginning.

```bash
# pass 1: build a palette from the segment you are actually using
ffmpeg -ss 15 -t 11 -i "recording.mov" \
  -vf "fps=15,scale='min(540,iw)':-1:flags=lanczos,palettegen=max_colors=256:stats_mode=diff" \
  pal.png

# pass 2: apply it
ffmpeg -ss 15 -t 11 -i "recording.mov" -i pal.png \
  -lavfi "fps=15,scale='min(540,iw)':-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" \
  -loop 0 media/app-demo.gif
```

Two passes, always. A single-pass GIF uses a generic 216-color web palette and
looks like 1998.

### The flags that decide quality and size

Measured on the same five-frame 414x900 slideshow, which is why these numbers
are directly comparable:

| Settings | Size | Verdict |
|---|---|---|
| 12fps, `bayer_scale=3`, no diff mode | 700 KB | The old default. Visible checkerboard on dark areas |
| 15fps, `bayer_scale=5`, `diff_mode=rectangle` | 616 KB | **Higher frame rate, cleaner, and smaller. Use this** |
| 15fps, `dither=none`, `diff_mode=rectangle` | 584 KB | Cleanest and smallest on flat UI. Can band on photos |
| 15fps, `dither=sierra2_4a`, `diff_mode=rectangle` | 5.7 MB | Nine times larger. Never do this |

Reading that table:

- **`diff_mode=rectangle` is free.** It tells `paletteuse` to only rewrite the
  rectangle that changed between frames, which is most of what a screencast is.
  Nothing to trade off
- **`bayer_scale=5` beats `bayer_scale=3` on both axes.** Larger scale means a
  coarser, less noisy dither pattern, which compresses better *and* looks
  cleaner. `bayer_scale=3` is the visible checkerboard on dark backgrounds
- **Error diffusion is a trap.** `sierra2_4a` and `floyd_steinberg` look great on
  one still image and are catastrophic across frames: the dither noise changes
  everywhere on every frame, so inter-frame compression stops working entirely.
  Nine times the size for a worse result
- **`dither=none` is the right call for flat UI.** Solid fills, no photography,
  no gradients: it is smaller and has no pattern at all. Check for banding in
  any gradient before committing to it
- **`stats_mode=diff`** weights the palette toward pixels that change between
  frames, which is what a UI recording mostly is. Use `stats_mode=full` when the
  whole frame matters, such as a slideshow of unrelated screens

Frame rate: 15fps is smooth enough for UI, 12fps is acceptable and about 20%
smaller, and above 20fps a screencast gains almost nothing visible while size
grows roughly in proportion.

If it comes in over budget, cut **duration** first, then frame rate, and drop
resolution last. Eleven sharp seconds beat twenty blurry ones.

## 5. No recording? Slideshow GIF from stills

Perfectly legitimate when the interesting thing is a set of states rather than a
flow: themes, layouts, empty and loading and error. Caption it for what it is
("eight face styles"), not as a screen recording.

Normalize every frame to one canvas first. If frame sizes differ at all, `tile`
and `palettegen` silently produce a truncated GIF with no error.

Then route the stills through an intermediate mp4 rather than feeding the glob
straight into `paletteuse`. Doing it in one step fails on ffmpeg 8.x with
`Error while filtering: Internal bug, should not have happened`, because the
image2 glob demuxer and the single-image palette input do not agree on when the
stream ends. The intermediate file costs one command and sidesteps it entirely.

```bash
# 1. normalize each frame to an identical canvas, at the stills' native size
mkdir -p norm
i=1
for f in shot_*.png; do
  ffmpeg -y -loglevel error -i "$f" \
    -vf "scale=828:1792:force_original_aspect_ratio=decrease:flags=lanczos,pad=828:1792:(ow-iw)/2:(oh-ih)/2:0x0d1117" \
    "norm/f_$i.png"
  i=$((i+1))
done

# 2. stills to video, one frame per ~1.2s
ffmpeg -y -loglevel error -framerate 0.85 -pattern_type glob -i 'norm/f_*.png' \
  -c:v libx264 -pix_fmt yuv420p -crf 18 -r 15 slides.mp4

# 3. two-pass palette from the video
ffmpeg -y -loglevel error -i slides.mp4 \
  -vf "fps=15,palettegen=max_colors=256:stats_mode=full" pal.png
ffmpeg -y -loglevel error -i slides.mp4 -i pal.png \
  -lavfi "fps=15[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" \
  -loop 0 media/app-demo.gif
```

Set the canvas in step 1 to the stills' own dimensions, or 2x the display width,
whichever is smaller. `828x1792` suits full-resolution iPhone screenshots shown
at `width="270"`. Use `stats_mode=full` here rather than `diff`, since
consecutive slides are unrelated images and there is no useful frame-to-frame
delta to weight toward.

Pad with the page background (`0x0d1117` is GitHub dark) rather than pure black,
so the letterboxing does not read as part of the screenshot.

Then confirm the result, since a truncated GIF fails silently:

```bash
ffprobe -v error -select_streams v:0 -show_entries stream=nb_frames,width,height \
  -of default=noprint_wrappers=1 media/app-demo.gif
```

At 15fps with ~1.2s per still, expect roughly `stills * 18` frames. A count near
`stills` alone means the palette pass collapsed the timing; a count far below
that means frames were dropped. Then contact sheet the finished GIF and look at
it, which is the only check that catches a wrong or missing slide:

```bash
ffmpeg -y -i media/app-demo.gif -vf "fps=1/1.1,scale=200:-1,tile=5x1" -frames:v 1 check.png
```

## 6. Screenshots

Keep the originals. Downsize once, to 2x the width the README displays them at,
and never from an already-downsized copy.

```bash
sips -Z 900 ~/Desktop/Screens/01-welcome.png --out screenshots/gestures.png
```

`-Z` fits the longest side to 900px and preserves aspect ratio, which lands
around 2x for a cell displayed at `width="230"`. For a full-width hero
screenshot displayed at 640, use `-Z 1400` instead.

The destination name is what ends up in alt text, so it should say what the
screenshot shows. Rename after step 7, once the contact sheet has confirmed what
each file actually contains.

```bash
mkdir -p screenshots
for f in ~/Desktop/Screens/*.png; do
  sips -Z 900 "$f" --out "screenshots/$(basename "$f")"
done
```

If a downsized PNG is still large, `pngquant --quality=80-95 screenshots/*.png`
typically halves it with no visible change on UI screenshots. Compare before and
after at 1:1 rather than trusting the number.

## 7. Verify captions against the actual files

The highest-value step in this file. Timestamped filenames say nothing about
content, and two adjacent captures are often the same screen at different scroll
positions. Contact sheet the final set, in filename order, and read it before
writing captions:

```bash
mkdir -p norm
for f in screenshots/*.png; do
  ffmpeg -y -loglevel error -i "$f" \
    -vf "scale=200:250:force_original_aspect_ratio=decrease,pad=200:250:(ow-iw)/2:(oh-ih)/2:0x333333" \
    "norm/$(basename "$f")"
done
ffmpeg -y -pattern_type glob -i 'norm/*.png' -vf tile=8x2 -frames:v 1 check.png
```

Read `check.png` left to right, top row first, and match each tile to its
filename. Mislabeling `time-only-face.png` when the file is actually a symptom
picker is the kind of error a reviewer catches and the author never does.

If two screenshots really are near-duplicates, cut one or write the caption
around the part that differs.

## 8. Size and sanity checks

```bash
# what will actually be served on every page view
du -h media/* screenshots/* | sort -h

# confirm dimensions and frame count came out as intended
ffprobe -v error -select_streams v:0 \
  -show_entries stream=nb_frames,width,height \
  -of default=noprint_wrappers=1 media/app-demo.gif
```

Targets with the quality-first defaults above:

| Asset | Budget | Why |
|---|---|---|
| Hero GIF | under 3 MB | Loads on every page view, including on phones |
| mp4 | under 5 MB | Only downloaded when someone clicks |
| Each screenshot | under 400 KB | A table of six adds up fast |

To confirm a GIF is actually sharper rather than just larger, crop the same
region from the old and new files at 1:1 and stack them:

```bash
ffmpeg -y -i old.gif -vf "select=eq(n\,3),crop=300:150:0:80,scale=828:-1:flags=neighbor" -frames:v 1 a.png
ffmpeg -y -i new.gif -vf "select=eq(n\,3),crop=414:207:0:110,scale=828:-1:flags=neighbor" -frames:v 1 b.png
ffmpeg -y -i a.png -i b.png -filter_complex "[0:v]pad=828:ih+8:0:8:0x00aaff[a];[a][1:v]vstack" -frames:v 1 compare.png
```

`flags=neighbor` zooms without smoothing, so dither patterns and soft edges are
visible instead of being blurred away by the comparison itself.

## 9. When high res will not fit

If the GIF cannot be both sharp and under budget, stop fighting the format. GIF
is capped at 256 colors and has no real inter-frame compression, so past a
point the only lever left is throwing away pixels.

Two ways out, in order of preference:

**Upload the mp4 to GitHub and embed the returned URL.** Dragging a video file
into any issue, PR, or comment box on github.com returns a
`https://github.com/user-attachments/assets/...` URL, and that URL pasted into
the README renders as a real video player at full resolution with sound. A
relative path to an mp4 committed in the repo does not do this, which is the
thing everyone tries first. The upload limit is 10 MB per video, and the file
lives on GitHub's CDN rather than in the repo, so it costs nothing to clone.

That is the only way to put genuinely high-resolution motion on a README. Do the
upload manually, since it is a publish action through the web UI.

**Or keep a short sharp GIF and link the long one.** Six seconds at full
resolution as the hero, with the complete walkthrough behind the mp4 link. The
hero exists to stop the scroll, not to show every feature.

## Cleanup

`pal.png`, `sheet.png`, `check.png`, `compare.png`, `slides.mp4`, and `norm/` are
working files. Delete them before `git add`, or the leak check in the ship step
will flag them.

```bash
rm -rf pal.png sheet.png check.png compare.png slides.mp4 norm/
```
