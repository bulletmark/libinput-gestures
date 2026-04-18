### LIBINPUT-GESTURES
[![AUR](https://img.shields.io/aur/version/libinput-gestures)](https://aur.archlinux.org/packages/libinput-gestures/)

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

Note that [libinput does not interpret gestures for
touchscreens](https://wayland.freedesktop.org/libinput/doc/latest/gestures.html#touchscreen-gestures)
so this utility can only be used for a touchpad, not a touchscreen.

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

You need Python 3.8 or later, Python2 is not supported. You need the `libinput`
package. The `libinput-tools` package must be installed if your system packages
the tools separately.

You **must be a member of the _input_ group** to have permission
to read the touchpad device:

    sudo gpasswd -a $USER input

After executing the above command, reboot your system.

**Note** adding yourself to the `input` group makes ALL `/dev/input`
devices readable by your user account and some consider this a security
risk. If you are concerned then consider adding a udev rule to apply a
dynamic user ACL as [described
here](https://wiki.archlinux.org/title/Udev#Allowing_regular_users_to_use_devices),
rather than adding yourself to the `input` group.

Most/many users will require to install the following although neither are
actual dependencies because some custom configurations will not require
them. If you are unsure initially, install both of them.

|Prerequisite|Required for |
|------------|-------------|
|`wmctrl`    |Necessary for `_internal` command, as per default configuration|
|`xdotool`   |Simulates keyboard and mouse actions for Xorg or XWayland based apps|
|`python3-evdev`|Necessary for `_drag` command (continuous drag/text selection on Wayland)|

    # E.g. On Arch:
    sudo pacman -S wmctrl xdotool python-evdev

    # E.g. On Debian based systems, e.g. Ubuntu:
    sudo apt-get install wmctrl xdotool python3-evdev

    # E.g. On Fedora:
    sudo dnf install wmctrl xdotool python3-evdev

The `_drag` command also requires write access to `/dev/uinput`. The
recommended approach is a udev rule:

    echo 'KERNEL=="uinput", MODE="0660", GROUP="input"' | sudo tee /etc/udev/rules.d/99-uinput.rules
    sudo udevadm control --reload-rules && sudo udevadm trigger

NOTE: Arch users can now just install [_libinput-gestures from the
AUR_][AUR]. Then skip to the next CONFIGURATION section.

Install this software:

    git clone https://github.com/bulletmark/libinput-gestures.git
    cd libinput-gestures
    sudo ./libinput-gestures-setup install

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
|`hold on`             |Open new web browser tab. See description of [hold gestures](#hold-gestures). |
|`hold on+N` (for `N` seconds, e.g. 1.5) |After extra hold time delay, close browser tab. See description of [hold gestures](#hold-gestures). |
|`drag drag`           |Continuous text selection / drag-and-drop. See description of [drag gestures](#drag-gestures). |

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
e.g. `~/bin/libinput-gestures.sh` with a `#!/bin/sh` shebang. Optionally
that script can take arguments. Run that script by hand until you get it
working then configure the script path as your command in your
`libinput-gestures.conf`.

In most cases, `libinput-gestures` automatically determines your
touchpad device. However, you can specify it in your configuration file
if needed. If you have multiple touchpads you can also specify
`libinput-gestures` to use all devices. See the notes in the default
`libinput-gestures.conf` file about the `device` configuration command.

### STARTING AND STOPPING

To [re-]start the app immediately and also to enable it to start
automatically at login, just type the following:

    libinput-gestures-setup stop desktop autostart start

The following commands are available:

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
action in sequence.

Note that on some uncommon systems then `libinput-gestures-setup start`
may fail to start the application returning you a message _Don't know
how to invoke libinput-gestures.desktop_. If you get this error message,
install the dex package, preferably from your system packages
repository, and try again.

### SYSTEMD USER SERVICE

By default, `libinput-gestures` is started with your DE as a desktop
application. There is also an option to start as a [systemd user
service](https://wiki.archlinux.org/title/Systemd/User). However, on
some systems this can be unreliable (on system restart, the application
will get started but occasionally will be unable to receive commands).
If you want to try it, type:

    libinput-gestures-setup stop service autostart start

You can switch back to the desktop option with the command:

    libinput-gestures-setup stop desktop autostart start

### UPGRADE

    # cd to source dir, as above
    git pull
    sudo ./libinput-gestures-setup install
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

GNOME 3.38 and earlier on Wayland natively implements the following
gestures:

- 3 finger pinch opens/close the GNOME overview.
- 4 finger swipe up/down changes workspaces

GNOME 40->46 on Wayland natively implements the following
gestures:

- 3 finger swipe up/down opens the GNOME overview.
- 3 finger swipe left/right changes workspaces

Note that GNOME 40->46 does not use 4 finger gestures so you can freely
assign them using `libinput-gestures`.

GNOME 47 and above implements the same gestures as GNOME 40->46 but also
duplicates those gestures to 4 finger gestures so you can't use them for
libinput-gestures unless you do one of the following to disable 3 finger
gestures in GNOME.

1. Install the [_Disable 3 Finger Gestures_](https://extensions.gnome.org/extension/7403/disable-3-finger-gestures/)
   GNOME shell extension. Note, this extension
   [does not work correctly since GNOME 49](https://github.com/lxp-git/disable-three-finger/issues/5).

2. Patch `gnome-shell` to stop it using 3 finger gestures using this
   [patch script](https://gist.github.com/bulletmark/0630478f98363adf584bbcfe8e527cb1).

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
1 or more fingers after holding them for a small time period and are
simply set ON as a trigger.
`libinput-gestures` interprets them to commands you can
configure in your `libinput-gestures.conf`, e.g:

    gesture hold on 4 xdotool key control+t

The above gesture will open a new tab in your browser if you rest 4
fingers statically on the touchpad. If you don't specify a finger count
then the command is executed when any number of fingers are used for the
hold.

Optionally, you can configure a time delay on hold gestures to map
longer hold times to different commands. Any extra hold time can be
specified, as an integer or float value in decimal seconds. E.g. `on+1`
is a hold + 1 extra second, `on+3.5` is a hold + 3.5 extra seconds, etc.
These can be configured in addition to `on` (which is effectively the
same as `on+0`), and also with different (or no specific) finger counts,
e.g:

    gesture hold on 4 xdotool key control+t
    gesture hold on+2.2 4 xdotool key control+w

The above will configure a second 4 finger hold gesture which, after 2.2
extra seconds to a normal hold, will close the current tab in your
browser. You can configure as many hold gestures, with different times
and finger counts (or no specific finger count), as you like but it will
quickly get unworkable if you add too many, or with close delays.

To get an idea of suitable hold times to configure, comment out all hold
gestures in your configuration file `libinput-gestures.conf` and run
with debug output. I.e. run `libinput-gestures -d` in a terminal window
(you may have to temporarily disable `libinput-gestures` first by
running `libinput-gestures-setup stop`). Then experiment with different
holds which will print the times to the screen so you can choose what to
configure for your hold gestures. Run `libinput-gestures-setup restart`
to restart `libinput-gestures` after updating your configuration.

### DRAG GESTURES

Drag gestures simulate holding mouse button 1 while tracking finger
movement, enabling continuous text selection and drag-and-drop. Unlike
swipe gestures which fire a single action at the end, drag gestures emit
mouse events in real time throughout the motion.

To enable 3-finger drag, add the following to your
`~/.config/libinput-gestures.conf`:

    gesture drag drag 3 _drag

The `_drag` internal command uses a persistent `uinput` virtual mouse
device to inject `BTN_LEFT` + relative mouse movement events. It works
natively with both Wayland and Xorg clients and requires `python3-evdev`
and write access to `/dev/uinput` (see [INSTALLATION](#installation)).

#### Lift-and-continue delay

An optional delay in milliseconds can be specified to enable
lift-and-continue behaviour — the mouse button is held for that duration
after fingers are lifted, allowing you to reposition fingers at the
touchpad edge and resume the selection:

    gesture drag drag 3 _drag 500

A new gesture with the same finger count within the delay window resumes
the drag seamlessly. Any other gesture (different finger count, tap,
etc.) ends the drag immediately regardless of the remaining delay.

#### GNOME Wayland note

On GNOME Wayland, the compositor intercepts 3-finger swipe gestures
natively. To free them up for drag gestures, install the [_Window
Gestures_](https://extensions.gnome.org/extension/4245/window-gestures/)
GNOME shell extension and set it to use 4 fingers (swapping the default
3/4 finger assignments). This moves workspace switching and window
management to 4-finger gestures, leaving 3 fingers available for
`libinput-gestures` drag.

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
   events received from `libinput debug-events`. You should see the
   following types of events when you move your fingers:

   - 1 and 2 finger movements should output `POINTER_*` type events
   - 3 (and above) finger movements should output `GESTURE_*` type events.

   If you do not see any `GESTURE_*` events then unfortunately your
   touchpad and/or libinput does not report multi-finger gestures so
   `libinput-gestures` can not work. The discrimination of
   gestures is done completely within libinput, before they get passed
   to `libinput-gestures`.

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
