**pacmixer** is an [alsamixer][alsamixer] alike for PulseAudio.

I started this, because I've found no full-blown, terminal based mixers available for PA. All there are are either [CLI][CLI] or some kinds of GNOME/KDE applets. That's not what I wanted, so in the end I decided to go for it myself.

It was also a good starting point to finally learn myself some ObjC :).

Back in the old days, there were a good mixer for ALSA (alsamixer), so I thought about taking some of their ideas, mix it with mine, and see what happens.

## requirements
* libpulse
* ncurses
* gcc-objc (for compilation)

## installation
Type
```sh
make
make install
```
and you're done.

## usage
**pacmixer** comes with built-in help, but here's the shortcuts reference, just in case.

```
h (or left arrow): move to the previous control
l (or right arrow): move to the next control
j (or down arrow): lower the volume
k (or up arrow): increase the volume
m: mute the volume
i: go into the inside mode
q: go outside the inside mode, or exit the application
```

#### inside mode
Inside mode is used to adjust specific channel's volume.

All shortcuts (besides ```q```) work the same, except that they affect single channels instead of the whole sink/source.

## screenshot
![screenshot](http://dl.dropbox.com/u/20714377/pacmixer2.png)

[alsamixer]: http://en.wikipedia.org/wiki/Alsamixer
[CLI]: http://en.wikipedia.org/wiki/Command-line_interface
