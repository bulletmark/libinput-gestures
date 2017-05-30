### LIBINPUT-GESTURES

[Libinput-gestures][REPO] is a utility which reads libinput gestures
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
the output of the _libinput-list-devices_ and _libinput-debug-events_
utilities so is a little fragile to any version changes in their output
format.

This utility is developed and tested on Arch linux using the GNOME 3 DE
on Xorg and Wayland. It works somewhat incompletely on Wayland (via
XWayland). See the WAYLAND section below and the comments in the default
`libinput-gestures.conf` file. It has been [reported to work with
KDE](http://www.lorenzobettini.it/2017/02/touchpad-gestures-in-linux-kde-with-libinput-gestures/).
I am not sure how well this will work on all distros and DE's etc.

The latest version and documentation is available at
http://github.com/bulletmark/libinput-gestures.

### INSTALLATION

IMPORTANT: You must be a member of the _input_ group to have permission
to read the touchpad device:

    sudo gpasswd -a $USER input

After executing the above command, **log out of your session
completely**, and then log back in to assign this group (or just
reboot).

NOTE: Arch users can just install [_libinput-gestures from the
AUR_][AUR]. Then skip to the next CONFIGURATION section.

You need python 3.4 or later, python2 is not supported. You also need
libinput release 1.0 or later. Install prerequisites:

    # E.g. On Arch:
    sudo pacman -S xdotool wmctrl

    # E.g. On Debian based systems, e.g. Ubuntu:
    sudo apt-get install xdotool wmctrl

    # E.g. On Fedora:
    sudo dnf install xdotool wmctrl

Debian and Ubuntu users also need to install `libinput-tools` if that
package exists in your release:

    sudo apt-get install libinput-tools
    

Fedora (from fedora 25 and newer) users needs to install `wmctrl` since wayland is the default window manager.

    sudo dnf install wmctrl

Install this software:

    git clone http://github.com/bulletmark/libinput-gestures
    cd libinput-gestures
    sudo ./libinput-gestures-setup install

### CONFIGURATION

Many users will be happy with the default configuration in which case
you can just type the following and you are ready to go:

    libinput-gestures-setup start
    libinput-gestures-setup autostart

Otherwise, if you want to create your own custom gestures etc, keep
reading ..

The default gestures are in `/etc/libinput-gestures.conf`. If you want
to create your own custom gestures then copy that file to
`~/.config/libinput-gestures.conf` and edit it. The available gestures
are:

- swipe up (e.g. map to GNOME/KDE/etc move to next workspace)
- swipe down (e.g map to GNOME/KDE/etc move to prev workspace)
- swipe left (e.g. map to Web browser go forward)
- swipe right (e.g. map to Web browser go back)
- pinch in (e.g. map to GNOME open/close overview)
- pinch out (e.g. map to GNOME open/close overview)

You can choose to specify a specific finger count, typically 3 or 4
fingers. If specified then the command is executed when exactly that
number of fingers is used in the gesture. If not specified then the
command is executed when that gesture is executed with any number of
fingers. Gestures specified with finger count have priority over the
same gesture specified without any finger count.

Of course, 2 finger swipes and taps are already interpreted by your DE
and apps for scrolling etc.

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

### STARTING AND STOPPING

Search for, and then start, the libinput-gestures app in your DE or
you can start it immediately in the background using the command line
utility:

    libinput-gestures-setup start

You can stop the background app with:

    libinput-gestures-setup stop

You can enable the app to start automatically in the background when you
log in (on an XDG compliant DE such as GNOME and KDE) with:

    libinput-gestures-setup autostart

You can disable the app from starting automatically with:

    libinput-gestures-setup autostop

You can restart the app or reload the configuration file with:

    libinput-gestures-setup restart

You can check the status of the app with:

    libinput-gestures-setup status

### UPGRADE

    # cd to source dir, as above
    git pull
    sudo ./libinput-gestures-setup install
    libinput-gestures-setup restart

### REMOVAL

    libinput-gestures-setup stop
    libinput-gestures-setup autostop
    sudo libinput-gestures-setup uninstall

### WAYLAND AND OTHER NOTES

This utility exploits `xdotool` which unfortunately only works with
X11/Xorg based applications. So `xdotool` shortcuts for the desktop do
not work under GNOME on Wayland which is now the default since GNOME
3.22. However, it is found that `wmctrl` desktop selection commands do work
under GNOME on Wayland (via XWayland) so this utility adds a built-in
`_internal` command which can be used to switch workspaces using the
swipe commands.
The `_internal` `ws_up` and `ws_down` commands use `wmctrl` to work out
the current workspace and select the next one. Since this works on both
Wayland and Xorg, and with GNOME, KDE, and other EWMH compliant
desktops, it is now the default configuration command for swipe up and
down commands in `libinput-gestures.conf`. See the comments in that file
about other options you can do with the `_internal` command.
Unfortunately `_internal` does not currently work with Compiz for Ubuntu
Unity desktop so also see the explicit example there for Unity.

Of course, `xdotool` commands do work via XWayland for Xorg based apps
so, for example, page forward/back swipe gestures do work for Firefox
and Chrome browsers when running on Wayland as per the default
configuration.

Note if your touchpad is capable of reporting 4 finger gestures and you
are using GNOME on Wayland then you can already switch workspaces using
4 finger swipe up and down gestures natively provided by GNOME. That is
the only desktop touchpad gesture GNOME currently provides. In that
case, if you still choose to run `libinput-gestures` to get extra
gestures, be sure to disable the default `libinput-gestures` swipe
up/down, or at least configure swipe up/down only for 3 fingers.

### EXTENDED GESTURES

They are not enabled in the default `libinput-gestures.conf`
configuration file but you can enable extended gestures which augment
the gestures listed above in CONFIGURATION. See the commented out
examples in `libinput-gestures.conf`.

- swipe right_up (e.g. jump to next open browser tab)
- swipe left_up (e.g. jump to previous open browser tab)
- swipe left_down (e.g. close current browser tab)
- swipe right_down (e.g. reopen and jump to last closed browser tab)
- swipe pinch clockwise
- swipe pinch anticlockwise

So instead of just configuring swipe up/down and left/right each at 90
degrees, you can add the above extra 4 swipes for 45 degree swipes to
give a total of 8 swipe gestures over 360 degrees. It works better than
you may expect, at least after some practice. It means you can
completely manage browser tabs from your touchpad.

### TROUBLESHOOTING

Please don't raise a github issue but provide little information about
your problem.

1. Ensure you are running the latest version from the
   [libinput-gestures github repository][REPO] or from the [Arch AUR][AUR].

2. Ensure you have followed the installation instructions here
   carefully. The most common mistake is that you have not added your
   user to the _input_ group and re-logged in as described above.

3. Perhaps temporarily remove your custom configuration to try with the
   default configuration.

4. Run `libinput-gestures` on the command line in debug mode while
   performing some 3 and 4 finger left/right/up/down swipes, and some
   pinch in/outs. In debug mode, configured commands are not executed,
   they are merely output to the screen:
    ````
	libinput-gestures-setup stop
	libinput-gestures -d
	(<ctrl-c> to stop)
    ````
5. Run `libinput-gestures` in raw mode by repeating the same commands as
   above step but use the `-r` (--raw) switch instead of `-d` (--debug).
   Raw mode does nothing more than echo the raw gesture events received
   from `libinput-debug-events`. If you see POINTER_* events but no
   GESTURE_* events then unfortunately your touchpad and/or libinput
   combination can report simple finger movements but does not report
   multi-finger gestures so `libinput-gestures` will not work.

6. Search the web for Linux kernel and/or libinput issues relating to
   your specific touchpad device and/or laptop/pc. Update your BIOS if
   possible.

7. If you raise an issue, **always** include the output of
   `libinput-gestures -e` to show the environment you are using.
    Also paste the output from steps 3 and 4 above.
    If appropriate, paste the output of `libinput-gestures -l` to
    show what gestures you have configured.

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
Public License at <http://www.gnu.org/licenses/> for more details.

[REPO]: https://github.com/bulletmark/libinput-gestures/
[AUR]: https://aur.archlinux.org/packages/libinput-gestures/
[XDOTOOL]: http://www.semicomplete.com/projects/xdotool/

<!-- vim: se ai syn=markdown: -->
