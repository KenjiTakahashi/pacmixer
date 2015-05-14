[![Build Status](https://travis-ci.org/KenjiTakahashi/pacmixer.png?branch=master)](https://travis-ci.org/KenjiTakahashi/pacmixer)

**pacmixer** is an [alsamixer][alsamixer] alike for PulseAudio.

I started this, because I've found no full-blown, terminal based mixers available for PA. All there are are either [CLI][CLI] or some kinds of GNOME/KDE applets. That's not what I wanted, so in the end I decided to go for it myself.

It was also a good starting point to finally learn myself some ObjC :).

Back in the old days, there were a good mixer for ALSA (alsamixer), so I thought about taking some of their ideas, mix it with mine, and see what happens.

## screenshot
![screenshot](https://copy.com/VWeHEkhBtCsr)

## requirements
* libpulse
* ncurses
* gnustep-base
* gcc-objc (for compilation)
* ninja (for compilation)

## installation
Type
```sh
# ./mk install
```
and you're done.

## usage
**Note:** There is also an introductory video available [here](http://www.youtube.com/watch?v=s3qk_Fn1Yeo), thanks to [**@gotbletu**](https://github.com/gotbletu).

**pacmixer** comes with built-in help, but here's the shortcuts reference, just in case.

```
h (or left arrow): move to the previous control
l (or right arrow): move to the next control
k (or up arrow): increase the volume
j (or down arrow): lower the volume
m: mute the volume
d: set as default
i: enter inside mode
s: enter settings mode
q (or Esc): exit settings/inside mode or exit the application
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

**Note:** Tired of the `~/GNUstep` directory? Rename it and replace the value of `GNUSTEP_USER_DEFAULTS_DIR` variable in the `/etc/GNUstep/GNUstep.conf` file.

#### inside mode
Used to adjust specific channel's volume.

All shortcuts (besides ```q```) work the same, except that they affect single channel instead of the whole sink/source.

#### settings mode
Used to change controls settings (e.g. ports).

Shortcuts work like in outside mode, except that:

* `space` is used to check setting.
* `h` and `l` iterate only over controls which actually have settings.

## something's broken?

Please compile **pacmixer** using
```sh
$ make debug
```
then run it, reproduce the problem and send the contents of ```~/.pacmixer.log``` file with your bug report.

That will make it easier to identify the problem.

## tests

Type
```sh
$ ./mk tests
$ ./pacmixer_run_tests
```

**Note:** You will need `g++` for this.

**Note:** It is a [Catch][catch] executable, all [options] apply.

[alsamixer]: http://en.wikipedia.org/wiki/Alsamixer
[CLI]: http://en.wikipedia.org/wiki/Command-line_interface
[catch]: https://github.com/philsquared/Catch
[options]: https://github.com/philsquared/Catch/wiki/Command-line
