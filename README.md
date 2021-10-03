# Hourglass
Hourglass is a simple time keeping application designed for elementary OS.

Author: [Samuel Thomas](https://github.com/sgpthomas) \<sgpthomas@gmail.com\>

![](data/screenshots/alarm.png)
![](data/screenshots/stopwatch.png)
![](data/screenshots/timer.png)

## Installation
### For Users
On elementary OS? Click the button to get Hourglass on AppCenter:

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.sgpthomas.hourglass)

### For Developers
You'll need the following dependencies to build:
* libgranite-dev (>= 6.0.0)
* libgtk-3-dev
* libhandy-1-dev
* meson (>= 0.49.0)
* valac

Run `meson build` to configure the build environment and then change to the build directory and run `ninja` to build

    meson build --prefix=/usr 
    cd build
    ninja

To install, use `ninja install`, then execute with `com.github.sgpthomas.hourglass`

    ninja install
    com.github.sgpthomas.hourglass
