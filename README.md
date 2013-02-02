**pacmixer** is an [alsamixer][alsamixer] alike for PulseAudio.

I started this, because I've found no full-blown, terminal based mixers available for PA. All there are are either [CLI][CLI] or some kinds of GNOME/KDE applets. That's not what I wanted, so in the end I decided to go for it myself.

It was also a good starting point to finally learn myself some ObjC :).

Back in the old days, there were a good mixer for ALSA (alsamixer), so I thought about taking some of their ideas, mix it with mine, and see what happens.

## screenshot
![screenshot](http://dl.dropbox.com/u/20714377/pacmixer2.png)

## requirements
* libpulse
* ncurses
* gnustep-base
* gcc-objc (for compilation)

## installation
Type
```sh
$ make
# make install
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
q (or Esc): go outside the inside mode or exit the application
F1-F5 (or 1-5): switch to all/playback/recording/outputs/inputs view, respectively
F12 (or 0): switch to settings view
```

#### settings view
Used to change card wise settings (e.g. profiles) and control views filters.

```
h (or left arrow): move to the previous group of settings
l (or right arrow): move to the next group of settings
k (or up arrow): move to the previous setting within group
j (or down arrow): move to the next setting within group
space: (un)check highlighted setting
q (or Esc): exit the application
```

**Note:** All settings are applied and saved automatically.

#### inside mode
Used to adjust specific channel's volume.

All shortcuts (besides ```q```) work the same, except that they affect single channel instead of the whole sink/source.

## something's broken?

Please compile **pacmixer** using
```sh
$ make debug
```
then run it, reproduce the problem and send the contents of ```~/.pacmixer.log``` file with your bug report.

That will make it easier to identify the problem.

[alsamixer]: http://en.wikipedia.org/wiki/Alsamixer
[CLI]: http://en.wikipedia.org/wiki/Command-line_interface
