# wails-test

A test of packaging a Wails app for Linux.

## Makefile

Check out the Makefile for annotated examples of how to build various targets, including...

### tgz

`make tgz`

It's a very simple target for creating a *.tgz file.

### flatpak

`make flatpak`

The `flatpak`, `flatpak-run` and `flatpak-install` targets show various ways to just test that a Flatpak can be built, build then run it, or build then install for the current user respectively.

Because `flatpak-builder` does not allow build tools to download anything from the internet, it's pretty difficult to fully build a Wails project from source. This is discussed in Always Developing session #57:

https://youtu.be/N6lvl4ePCYI

The Flatpak manifest is at [flatpak/com.ianmjones.wails-test.yml](flatpak/com.ianmjones.wails-test.yml).

### snap

`make snap`

The `snap`, `snap-debug` and `snap-prime-shell` targets show various ways to just build a snap, build and drop into a shell if there are problems, or drop into a shell just before it finishes so you can look at the files respectively.

To see how the snapcraft.yaml was iteratively built, check out Always Developing session #59:

https://youtu.be/prwJ0MfjnHQ

The snapcraft template is at [snap/snapcraft.yaml](snap/snapcraft.yaml).

---

Originally built for https://github.com/wailsapp/wails/discussions/779
