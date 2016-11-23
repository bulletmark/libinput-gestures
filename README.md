### LIBINPUT-GESTURES

[Libinput-gestures](https://github.com/bulletmark/libinput-gestures) is
a utility which reads libinput gestures from your touchpad and maps them
to gestures you configure in a configuration file. Each gesture can be
configured to activate a shell command which is typically an
[_xdotool_](http://www.semicomplete.com/projects/xdotool/) command to
action desktop/window/application keyboard combinations and commands.
See the examples in the provided `libinput-gestures.conf` file. My
motivation for creating this is to use triple swipe up/down to switch
GNOME workspaces, and triple swipe left/right to go backwards/forwards
in my browser, as per the default configuration.

This small and simple utility is only intended to be used temporarily
until GNOME and other DE's action libinput gestures natively. It parses
the output of the _libinput-list-devices_ and _libinput-debug-events_
utilties so is a little fragile to any version changes in their output
format.

This utility is developed and tested on Arch linux with the GNOME 3 DE
on Xorg. I am not sure how well this will work on other distros and
other DE's etc.

The latest version and documentation is available at
http://github.com/bulletmark/libinput-gestures.

### INSTALLATION

IMPORTANT: You must be a member of the _input_ group to have permission
to read the touchpad device:

    sudo gpasswd -a $USER input  # Log out and back in to assign this group

NOTE: Arch users can just install [_libinput-gestures from the
AUR_](https://aur.archlinux.org/packages/libinput-gestures/). Then skip
to the next CONFIGURATION section.

You need libinput release 1.0 or later. Install prerequisites:

    # On Arch:
    sudo pacman -S xdotool wmctrl

    # Or, on Debian based systems, e.g. Ubuntu:
    sudo apt-get install xdotool wmctrl

Debian and Ubuntu users also need to install `libinput-tools` if that
package exists in your release:

    sudo apt-get install libinput-tools
    

Fedora (from fedora 25 and newer) users needs to install `wmctrl` since wayland is the default window manager.

    sudo dnf install wmctrl

Install this software:

    git clone http://github.com/bulletmark/libinput-gestures
    cd libinput-gestures
    sudo make install

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

- swipe up (e.g. map to GNOME move to prev workspace)
- swipe down (e.g map to GNOME move to next workspace)
- swipe left (e.g. map to GNOME/Browser go back)
- swipe right (e.g. map to GNOME/Browser go forward)
- pinch in (e.g. map to GNOME open/close overview)
- pinch out (e.g. map to GNOME open/close overview)

You can choose to specify a specific finger count, typically 3 or 4
fingers. If specified then the command is executed when exactly that
number of fingers is used in the gesture. If not specified then the
command is executed when that gesture is executed with any number of
fingers. Gestures specified with finger count have priority over the
same gesture specified without any finger count.

Of course, 2 finger swipes and taps are already interpreted by GNOME or
your DE and apps for scrolling etc.

IMPORTANT: Test the program. Check for reported errors in your custom
gestures, missing packages, etc:

    # Ensure the program is stopped
    libinput-gestures-setup stop

    # Test to print out commands that would be executed:
    libinput-gestures -d
    (<ctrl-c> to stop)

    # And/or test to print out commands as they are executed:
    libinput-gestures -v
    (<ctrl-c> to stop)

Confirm that the correct commands are reported for your 3 finger
swipe left/right/up/down gestures, and your 2 or 3 finger pinch
in/out gestures. Some touchpads can also support 4 finger gestures.

### STARTING AND STOPPING

Search for, and then start, the libinput-gestures app in your DE or
you can start it immediately in the background using the command line
utility:

    libinput-gestures-setup start

You can stop the background app with:

    libinput-gestures-setup stop

You can enable the app to start automatically in the background when you
log in with:

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
    sudo make install
    libinput-gestures-setup restart

### REMOVAL

    libinput-gestures-setup stop
    libinput-gestures-setup autostop
    sudo libinput-gestures-setup uninstall

### WAYLAND AND OTHER NOTES

This utility exploits `xdotool` which unfortunately only works with
X11/Xorg based applications. So keyboard shortcuts for the desktop do
not work under GNOME on Wayland which is now the default since GNOME
3.22. However, it seems that `wmctrl` EWMH commands do work under GNOME
on Wayland so this utility adds an `_internal` command which can be used
to switch workspaces using the swipe commands. The `_internal` command
uses `wmctrl` to work out which is the current workspace and then
selects the next one. Since this works on both Wayland and Xorg (and
with GNOME, KDE, and other EWMH compliant desktops), it is now the
default configuration command for swipe up and down commands.

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

<!-- vim: se ai syn=markdown: -->
