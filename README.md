[![Build Status](https://travis-ci.org/KenjiTakahashi/pacmixer.png?branch=master)](https://travis-ci.org/KenjiTakahashi/pacmixer)

**pacmixer** is an [alsamixer][alsamixer] alike for PulseAudio.

I started this, because I've found no full-blown, terminal based mixers available for PA. All there are are either [CLI][CLI] or some kinds of GNOME/KDE applets. That's not what I wanted, so in the end I decided to go for it myself.

It was also a good starting point to finally learn myself some ObjC :).

Back in the old days, there were a good mixer for ALSA (alsamixer), so I thought about taking some of their ideas, mix it with mine, and see what happens.

**Updating past 0.5:** Configuration mechanism has been reworked to be more flexible and integrate better with GNU/Linux environment. It means that:

* Pacmixer configuration is no longer available through settings tab (it is reserved for PA options).
* Settings are now configured using [configuration file](https://github.com/KenjiTakahashi/pacmixer#configuration).
* Settings configured with version <= 0.5 will be reset to defaults after update.
* Settings storage follows XDG => No more creepy "GNUStep" directory.

## screenshot
![screenshot](https://copy.com/VWeHEkhBtCsr)

## requirements
* libpulse
* ncurses
* gnustep-base
* gcc-objc (for compilation)
* ninja (for compilation)

## installation
```sh
# ./mk install
```

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
Used to change card wise settings (e.g. profiles).

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

All shortcuts (besides `q`) work the same, except that they affect single channel instead of the whole sink/source.

#### settings mode
Used to change controls settings (e.g. ports).

Shortcuts work like in outside mode, except that:

* `space` is used to check setting.
* `h` and `l` iterate only over controls which actually have settings.

## configuration
Pacmixer uses [toml](https://github.com/toml-lang/toml) based configuration file stored in `$XDG_CONFIG_HOME/pacmixer/settings.toml` (or `$HOME/.config/pacmixer/settings.toml`).

When run for the first time, it will create a new file with all configuration options set to their defaults. You can use this file as a basis and/or checkout the reference below.

**[Display]**

`StartScreen` (string) - Sets which screen should be visible when starting pacmixer. Available values are "All", "Playback", "Recording", "Outputs", "Inputs" and "Settings".

**[Filter]**

`Monitors` (boolean) - Filters out Monitor controls.

`Internals` (boolean) - Filters out PA internal controls.

**[Log]**

`Dir` (string) - Directory where log file(s) will be stored. Leave empty string to disable logging.

## something's broken?

Please include the log file (`$HOME/.local/share/pacmixer/pacmixer.log` by default) with your bug report.

That will make it easier to identify the problem.

## tests

Type
```sh
$ ./mk tests
$ ./pacmixer_run_tests
```

**Note:** It is a [Catch][catch] executable, all [options] apply.

[alsamixer]: http://en.wikipedia.org/wiki/Alsamixer
[CLI]: http://en.wikipedia.org/wiki/Command-line_interface
[catch]: https://github.com/philsquared/Catch
[options]: https://github.com/philsquared/Catch/wiki/Command-line
