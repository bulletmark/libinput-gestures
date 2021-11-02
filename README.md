### LIBINPUT-GESTURES

[Libinput-gestures][REPO] is a utility which reads [libinput
gestures](https://wayland.freedesktop.org/libinput/doc/latest/gestures.html)
from your touchpad and maps them to gestures you configure in a
configuration file. Each gesture can be configured to activate a shell
command which is typically an [_xdotool_][XDOTOOL] command to action
desktop/window/application keyboard combinations and commands. See the
examples in the provided `libinput-gestures.conf` file. My motivation
for creating this is to use triple swipe up/down to switch workspaces,
and triple swipe right/left to go backwards/forwards in my browser, as
per the default configuration.

This small and simple utility is only intended to be used temporarily
until GNOME and other DE's action libinput gestures natively. It parses
the output of the _libinput list-devices_ and _libinput debug-events_
utilities so is a little fragile to any version changes in their output
format.

This utility is developed and tested on Arch linux using the GNOME 3 DE
on Xorg and Wayland. It works somewhat incompletely on Wayland (via
XWayland). See the WAYLAND section below and the comments in the default
`libinput-gestures.conf` file. It has been [reported to work with
KDE](http://www.lorenzobettini.it/2017/02/touchpad-gestures-in-linux-kde-with-libinput-gestures/).
I am not sure how well this will work on all Linux systems and DE's etc.

The latest version and documentation is available at
https://github.com/bulletmark/libinput-gestures.

### INSTALLATION

You need python 3.5 or later, python2 is not supported. You also need
libinput release 1.0 or later.

You **must be a member of the _input_ group** to have permission
to read the touchpad device:

    sudo gpasswd -a $USER input

After executing the above command, reboot your system.

Most/many users will require to install the following although neither are
actual dependencies because some custom configurations will not require
them. If you are unsure initially, install both of them.

|Prerequisite|Required for |
|------------|-------------|
|`wmctrl`    |Necessary for `_internal` command, as per default configuration|
|`xdotool`   |Simulates keyboard and mouse actions for Xorg or XWayland based apps|

    # E.g. On Arch:
    sudo pacman -S wmctrl xdotool

    # E.g. On Debian based systems, e.g. Ubuntu:
    sudo apt-get install wmctrl xdotool

    # E.g. On Fedora:
    sudo dnf install wmctrl xdotool

NOTE: Arch users can now just install [_libinput-gestures from the
AUR_][AUR]. Then skip to the next CONFIGURATION section.

Debian and Ubuntu users may also need to install `libinput-tools` if
that package exists in your release:

    sudo apt-get install libinput-tools

Install this software:

    git clone https://github.com/bulletmark/libinput-gestures.git
    cd libinput-gestures
    sudo make install (or sudo ./libinput-gestures-setup install)

### CONFIGURATION

It is helpful to start by reading the documentation about [what libinput
calls gestures](https://wayland.freedesktop.org/libinput/doc/latest/gestures.html).
Many users will be happy with the default configuration in which case
you can just type the following and you are ready to go:

    libinput-gestures-setup autostart start

Otherwise, if you want to create your own custom gestures etc, keep
reading ..

The default gestures are in `/etc/libinput-gestures.conf`. If you want
to create your own custom gestures then copy that file to
`~/.config/libinput-gestures.conf` and edit it. There are many examples
and options described in that file. The available gestures are:

|Gesture               |Example Mapping |
|-------               |--------------- |
|`swipe up`            |GNOME/KDE/etc move to next workspace |
|`swipe down`          |GNOME/KDE/etc move to prev workspace |
|`swipe left`          |Web browser go forward |
|`swipe right`         |Web browser go back |
|`swipe left_up`       |Jump to next open web browser tab |
|`swipe left_down`     |Jump to previous open web browser tab |
|`swipe right_up`      |Close current web browser tab |
|`swipe right_down`    |Reopen and jump to last closed web browser tab |
|`pinch in`            |GNOME open/close overview |
|`pinch out`           |GNOME open/close overview |
|`pinch clockwise`     ||
|`pinch anticlockwise` ||
|`hold on` ([available since libinput 1.19](#hold-gestures)) |Open new web browser tab |

NOTE: If you don't use "natural" scrolling direction for your touchpad
then you may want to swap the default left/right and up/down
configurations.

You can choose to specify a specific finger count, typically [3 or more
fingers for swipe](https://wayland.freedesktop.org/libinput/doc/latest/gestures.html#swipe-gestures),
and [2 or more for pinch](https://wayland.freedesktop.org/libinput/doc/latest/gestures.html#pinch-gestures).
If a finger count is specified then the command is executed when exactly that
number of fingers is used in the gesture. If not specified then the
command is executed when that gesture is invoked with any number of
fingers. Gestures specified with finger count have priority over the
same gesture specified without any finger count.

Of course, 2 finger swipes and taps are already interpreted by your DE
and apps [for scrolling](https://wayland.freedesktop.org/libinput/doc/latest/scrolling.html#two-finger-scrolling) etc.

IMPORTANT: Test the program. Check for reported errors in your custom
gestures, missing packages, etc:

    # Ensure the program is stopped
    libinput-gestures-setup stop

    # Test to print out commands that would be executed:
    libinput-gestures -d
    (<ctrl-c> to stop)

Confirm that the correct commands are reported for your 3 finger
swipe up/down/left/right gestures, and your 2 or 3 finger pinch
in/out gestures. Some touchpads can also support 4 finger gestures.
If you have problems then follow the TROUBLESHOOTING steps below.

Apart from simple environment variable and `~` substitutions within the
configured command name, `libinput-gestures` does not run the configured
command under a shell so shell argument substitutions and expansions etc
will not be parsed. This is for efficiency and because most don't need
it. This also means your `PATH` is not respected of course so you must
specify the full path to any command. If you need something more
complicated, you can add your commands in an executable personal script,
e.g. `~/bin/libinput-gestures.sh` e.g. with a `#!/bin/sh` shebang . Run
that script by hand until you get it working then configure the script
path as your command in your `libinput-gestures.conf`.

In most cases, `libinput-gestures` automatically determines your
touchpad device. However, you can specify it in your configuration file
if needed. If you have multiple touchpads you can also specify
`libinput-gestures` to use all devices. See the notes in the default
`libinput-gestures.conf` file about the `device` configuration command.

### STARTING AND STOPPING

You must choose between starting the application as a [systemd user
service](https://wiki.archlinux.org/index.php/Systemd/User), or as a
[desktop
application](https://specifications.freedesktop.org/autostart-spec/autostart-spec-latest.html)
(with an XDG compliant DE such as GNOME and KDE). The systemd user
service option for `libinput-gestures` was added in Feb 2021 and
provides more robust management and better logging than the desktop so
is the preferred choice if your system is recent and your DM/DE supports
it. Note that some environments [do not correctly start the systemd
user
service](https://github.com/bulletmark/libinput-gestures/issues/305) so
you will have to choose the desktop option in that case.

Choose one of the two following options:

1. To set up the application as a [systemd user
   service](https://wiki.archlinux.org/index.php/Systemd/User):

````
libinput-gestures-setup service
````

2. Or instead, to set up the application using your
   [DE](https://specifications.freedesktop.org/autostart-spec/autostart-spec-latest.html):

````
libinput-gestures-setup desktop
````

After choosing one of the above, you can use then run the following commands:

Enable the app to start automatically in the background when you
log in with:

    libinput-gestures-setup autostart

Disable the app from starting automatically with:

    libinput-gestures-setup autostop

Start the app immediately in the background:

    libinput-gestures-setup start

Stop the background app immediately with:

    libinput-gestures-setup stop

Restart the app, e.g. to reload the configuration file, with:

    libinput-gestures-setup restart

Check the status of the app with:

    libinput-gestures-setup status

You can specify multiple user commands to `libinput-gestures-setup` to
action in sequence. E.g. to shutdown and change from a desktop
installation to running service installation type:

    libinput-gestures-setup stop service autostart start

Note if you are starting using the desktop option and you are using some
uncommon systems then `libinput-gestures-setup start` may fail to start
the application returning you a message _Don't know how to invoke
libinput-gestures.desktop_. If you get this error message, install the
dex package, preferably from your system packages repository, and try
again.

### UPGRADE

    # cd to source dir, as above
    git pull
    sudo make install (or sudo ./libinput-gestures-setup install)
    libinput-gestures-setup restart

### REMOVAL

    libinput-gestures-setup stop autostop
    sudo libinput-gestures-setup uninstall

### WAYLAND AND OTHER NOTES

This utility exploits `xdotool` for many use cases which unfortunately
only works with X11/Xorg based applications. So `xdotool` shortcuts for
the desktop do not work under GNOME on Wayland which is the default
since GNOME 3.22. However, it is found that `wmctrl` desktop selection
commands do work under GNOME on Wayland (via XWayland) so this utility
adds a built-in `_internal` command which can be used to switch
workspaces using the swipe commands. The `_internal` `ws_up` and
`ws_down` commands use `wmctrl` to work out the current workspace and
select the next one. Since this works on both Wayland and Xorg, and with
GNOME, KDE, and other EWMH compliant desktops, it is the default
configuration command for swipe up and down commands in
`libinput-gestures.conf`. See the comments in that file about other
options you can do with the `_internal` command. Unfortunately
`_internal` does not work with Compiz for Ubuntu Unity desktop so also
see the explicit example there for Unity.

Of course, `xdotool` commands do work via XWayland for Xorg based apps
so, for example, page forward/back swipe gestures do work for Firefox
and Chrome browsers when running on Wayland as per the default
configuration.

Note if you run `libinput-gestures` on GNOME with Wayland, be sure to
change or disable the your `libinput-gestures.conf` configured gestures
to not clash with the native gestures.

GNOME 40.0 and later on Wayland natively implements the following
gestures:

- 3 finger swipe up/down opens the GNOME overview.
- 3 finger swipe left/right changes workspaces

GNOME 40.0 does not use 4 finger gestures so you can freely assign them
using libinput-gestures.

GNOME 3.38 on Wayland and earlier natively implements the following
gestures:

- 3 finger pinch opens/close the GNOME overview.
- 4 finger swipe up/down changes workspaces

GNOME on Xorg does not natively implement any gestures.

### EXTENDED GESTURES

They are not enabled in the default `libinput-gestures.conf`
configuration file but you can enable extended gestures which augment
the gestures listed above in CONFIGURATION. See the commented out
examples in `libinput-gestures.conf`.

- `swipe right_up` (e.g. jump to next open browser tab)
- `swipe left_up` (e.g. jump to previous open browser tab)
- `swipe left_down` (e.g. close current browser tab)
- `swipe right_down` (e.g. reopen and jump to last closed browser tab)
- `pinch clockwise`
- `pinch anticlockwise`

So instead of just configuring the usual swipe up/down and left/right
each at 90 degrees separation, you can add the above extra 4 swipes to
give a total of 8 swipe gestures each at 45 degrees separation. It works
better than you may expect, at least after some practice. It means you
can completely manage browser tabs from your touchpad.

### HOLD GESTURES

Libinput version 1.19.0 added [HOLD
gestures](https://wayland.freedesktop.org/libinput/doc/latest/gestures.html#hold-gestures)
to augment the standard SWIPE and PINCH gestures. They are actioned with
1 or more fingers and are simply set ON as a trigger. They are not as
versatile as the other gestures but they are a distinct new gesture so
`libinput-gestures` does interpret them and map them to commands you can
configure in your `libinput-gestures.conf`, e.g:

    gesture hold on 4 xdotool key control+t

The above gesture will open a new tab in your browser if you rest 4
fingers statically on the window.

### AUTOMATIC STOP/RESTART ON D-BUS EVENTS SUCH AS SUSPEND

There are some situations where you may want to automatically stop,
start, or restart `libinput-gestures`. E.g. some touchpads have a
problem which causes `libinput-gestures` (actually the underlying
`libinput debug-events`) to hang after resuming from a system suspend so
those users want to stop `libinput-gestures` when a system goes into
suspend and then start it again with resuming. You can use a companion
program [`dbus-action`][DBUS] to
do this. See the example configuration for `libinput-gestures` in the
default [`dbus-action`][DBUS] [configuration
file](https://github.com/bulletmark/dbus-action/blob/master/dbus-action.conf).

The [`dbus-action`][DBUS] utility can also be used any similar
situation, e.g. when you remove/insert a detachable touchpad. It can be
used to stop, start, or restart `libinput-gestures` on any D-Bus event.

### TROUBLESHOOTING

Please don't raise a github issue but provide little information about
your problem, and please don't raise an issue until you have considered
all the following steps. **If you raise an issue ALWAYS include the
output of `libinput-gestures -l` to show the environment and
configuration you are using, regardless of what the issue is about**.

1. Ensure you are running the latest version from the
   [libinput-gestures github repository][REPO] or from the [Arch AUR][AUR].

2. Ensure you have followed the installation instructions here
   carefully. The most common mistake is that you have not added your
   user to the _input_ group and rebooted your system as described
   above.

3. Perhaps temporarily remove your custom configuration to try with the
   default configuration.

4. Run `libinput-gestures-setup status` and confirm it reports the set
   up that you expect.

5. Run `libinput-gestures` on the command line in debug mode while
   performing some 3 and 4 finger left/right/up/down swipes, and some
   pinch in/outs. In debug mode, configured commands are not executed,
   they are merely output to the screen:
   ````
	libinput-gestures-setup stop
	libinput-gestures -d
	(<ctrl-c> to stop)
   ````

6. Run `libinput-gestures` in raw mode by repeating the same commands as
   above step but use the `-r` (`--raw`) switch instead of `-d`
   (`--debug`). Raw mode does nothing more than echo the raw gesture
   events received from `libinput debug-events`. If you see `POINTER_*`
   events but no `GESTURE_*` events then unfortunately your touchpad
   and/or libinput combination can report simple finger movements but
   does not report multi-finger gestures so `libinput-gestures` will not
   work. Also note that discrimination of gestures is done completely
   within libinput, before they get to `libinput-gestures`.

7. Search the web for Linux kernel and/or libinput issues relating to
   your specific touchpad device and/or laptop/pc. Update your BIOS if
   possible.

8. Be sure that a configured external command works exactly how you want
   when you run it directly on the command line, **before** you configure
   it for `libinput-gestures`. E.g. run `xdotool` manually and
   experiment with various arguments to work out exactly what arguments
   it requires to do what you want, and only then add that command +
   arguments to your custom configuration in
   `~/.config/libinput-gestures.conf`. Clearly, if the your manual
   `xdotool` command does not work correctly then there is no point
   raising an `libinput-gestures` issue about it!

9. **If you raise an issue, always include the output of
   `libinput-gestures -l` to show the environment and configuration you
   are using**. If appropriate, also paste the output from steps 4 and 5
   above. If your device is not being recognised by `libinput-gestures`
   at all, paste the complete output of `libinput list-devices`
   (`libinput-list-devices` on libinput < v1.8).

### LICENSE

Copyright (C) 2015 Mark Blakeney. This program is distributed under the
terms of the GNU General Public License.
This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later
version.
This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License at <https://www.gnu.org/licenses/> for more details.

[REPO]: https://github.com/bulletmark/libinput-gestures/
[DBUS]: https://github.com/bulletmark/dbus-action/
[AUR]: https://aur.archlinux.org/packages/libinput-gestures/
[XDOTOOL]: https://www.semicomplete.com/projects/xdotool/

<!-- vim: se ai syn=markdown: -->
