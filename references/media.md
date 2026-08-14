# Media recipes

Every command needed to turn existing screenshots and a screen recording into a
hero GIF, a linked mp4, and a verified screenshot set. Requires `ffmpeg`
(`brew install ffmpeg`); `sips` ships with macOS.

## Contents

- [1. Contact sheet the recording](#1-contact-sheet-the-recording)
- [2. Encode the mp4](#2-encode-the-mp4)
- [3. Encode the hero GIF](#3-encode-the-hero-gif)
- [4. No recording? Slideshow GIF from stills](#4-no-recording-slideshow-gif-from-stills)
- [5. Downsize screenshots](#5-downsize-screenshots)
- [6. Verify captions against the actual files](#6-verify-captions-against-the-actual-files)
- [7. Size and sanity checks](#7-size-and-sanity-checks)

## 1. Contact sheet the recording

Do this before encoding anything. Recordings almost always open on a permission
alert and end on failed-thumbnail placeholder cards, and the only way to find the
clean stretch is to look at the whole thing at once.

```bash
# one frame every 2s, left to right, top row then bottom
ffmpeg -i "recording.mp4" -vf "fps=1/2,scale=170:-1,tile=10x2" -frames:v 1 sheet.png
```

Open `sheet.png` and read it. Frame N in the grid is at roughly `N * 2` seconds,
which gives the `-ss` start offset for both encodes below.

## 2. Encode the mp4

Full-quality demo, linked from the README rather than embedded. About 1.5 MB for
24 seconds.

```bash
ffmpeg -ss 3.5 -t 24 -i "recording.mp4" -vf "scale=620:-2" \
  -c:v libx264 -preset slow -crf 28 -pix_fmt yuv420p -movflags +faststart -an \
  media/app-demo.mp4
```

- `-ss` before `-i` seeks fast; `-t` is duration, not end time
- `scale=620:-2` keeps the aspect ratio and forces an even height, which h264
  requires
- `-an` drops audio, which a screencast does not need and which costs bytes
- `+faststart` moves the index to the front so it starts playing before it has
  fully downloaded

## 3. Encode the hero GIF

Two-pass palette generation, or it looks like 1998. About 2 MB for 11 seconds.
Pick the most visually interesting 10 to 15 seconds, not the beginning.

```bash
ffmpeg -ss 15 -t 11 -i "recording.mp4" \
  -vf "fps=12,scale=260:-1:flags=lanczos,palettegen=stats_mode=diff" pal.png

ffmpeg -ss 15 -t 11 -i "recording.mp4" -i pal.png \
  -lavfi "fps=12,scale=260:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=3" \
  media/app-demo.gif
```

Keep it under about 3 MB. It loads on every single page view, including from
phones. 12fps at 260px wide is plenty for a phone screencast; raise the fps only
if motion looks visibly choppy, and expect the file to grow roughly in
proportion.

`stats_mode=diff` weights the palette toward the pixels that change between
frames, which is what a UI recording is mostly made of.

## 4. No recording? Slideshow GIF from stills

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
# 1. normalize each frame to an identical canvas
mkdir -p norm
i=1
for f in shot_*.png; do
  ffmpeg -y -loglevel error -i "$f" \
    -vf "scale=300:652:force_original_aspect_ratio=decrease,pad=300:652:(ow-iw)/2:(oh-ih)/2:0x0d1117" \
    "norm/f_$i.png"
  i=$((i+1))
done

# 2. stills to video, one frame per ~1.2s
ffmpeg -y -loglevel error -framerate 0.85 -pattern_type glob -i 'norm/f_*.png' \
  -c:v libx264 -pix_fmt yuv420p -r 12 slides.mp4

# 3. two-pass palette from the video
ffmpeg -y -loglevel error -i slides.mp4 -vf "fps=12,palettegen=stats_mode=diff" pal.png
ffmpeg -y -loglevel error -i slides.mp4 -i pal.png \
  -lavfi "fps=12[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=3" \
  -loop 0 media/app-demo.gif
```

Pad with the page background (`0x0d1117` is GitHub dark) rather than pure black,
so the letterboxing does not read as part of the screenshot.

Then confirm the result, since a truncated GIF fails silently:

```bash
ffprobe -v error -select_streams v:0 -show_entries stream=nb_frames \
  -of default=nokey=1:noprint_wrappers=1 media/app-demo.gif
```

At `fps=12` with ~1.2s per still, expect roughly `stills * 14` frames. A count
near `stills` alone means the palette pass collapsed the timing; a count far
below that means frames were dropped. Then contact sheet the finished GIF and
look at it, which is the only check that catches a wrong or missing slide:

```bash
ffmpeg -y -i media/app-demo.gif -vf "fps=1/1.1,scale=150:-1,tile=5x1" -frames:v 1 check.png
```

## 5. Downsize screenshots

Full-resolution device screenshots are ~3 MB each. Nobody needs that on a README.

```bash
sips -Z 900 ~/Desktop/Screens/01-welcome.png --out screenshots/gestures.png
```

`-Z` fits the longest side to 900px and preserves aspect ratio. Rename in the
same command: the destination name is what shows up in alt text, so it should say
what the screenshot shows.

Batch version:

```bash
mkdir -p screenshots
for f in ~/Desktop/Screens/*.png; do
  sips -Z 900 "$f" --out "screenshots/$(basename "$f")"
done
# then rename each one descriptively, by hand, after step 6
```

## 6. Verify captions against the actual files

The highest-value step in this file. Timestamped filenames say nothing about
content, and two adjacent captures are often the same screen at different scroll
positions. Contact sheet the final set, in filename order, and read it before
writing captions:

```bash
mkdir -p norm
for f in screenshots/*.png; do
  ffmpeg -y -i "$f" \
    -vf "scale=200:250:force_original_aspect_ratio=decrease,pad=200:250:(ow-iw)/2:(oh-ih)/2:0x333333" \
    "norm/$(basename "$f")"
done
ffmpeg -y -pattern_type glob -i 'norm/*.png' -vf tile=8x2 -frames:v 1 check.png
```

Read `check.png` left to right, top row first, and match each tile to its
filename. Mislabelling `time-only-face.png` when the file is actually a symptom
picker is the kind of error a reviewer catches and the author never does.

If two screenshots really are near-duplicates, cut one or write the caption
around the part that differs.

## 7. Size and sanity checks

```bash
# what will actually be served on every page view
du -h media/* screenshots/* | sort -h

# confirm the GIF loops and has the expected frame count
ffprobe -v error -select_streams v:0 \
  -show_entries stream=nb_frames,width,height \
  -of default=noprint_wrappers=1 media/app-demo.gif
```

Targets: GIF under 3 MB, mp4 under 2 MB, each screenshot under about 400 KB.

## Cleanup

`pal.png`, `sheet.png`, `check.png`, `slides.mp4`, and `norm/` are working files.
Delete them before `git add`, or the leak check in the ship step will flag them.

```bash
rm -rf pal.png sheet.png check.png slides.mp4 norm/
```
