#!/usr/bin/env python3
"""
notif-logger — logs all desktop notifications to a file
Requires: python3-dbus, python3-gobject
Log file: ~/.local/share/notifications.log
"""

import datetime
import os
import dbus
import dbus.mainloop.glib
from gi.repository import GLib

LOG_FILE = os.path.expanduser("~/.local/share/notifications.log")
os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)


def on_notification(bus, message):
    if (
        message.get_interface() == "org.freedesktop.Notifications"
        and message.get_member() == "Notify"
    ):
        args = message.get_args_list()
        if len(args) < 5:
            return

        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        app     = str(args[0]) or "unknown"
        summary = str(args[3]) or ""
        body    = str(args[4]) or ""

        # Clean up body — strip HTML-like tags simply
        import re
        body = re.sub(r"<[^>]+>", "", body).strip()

        line = f"[{timestamp}] [{app}] {summary}"
        if body:
            line += f" — {body}"

        with open(LOG_FILE, "a", encoding="utf-8") as f:
            f.write(line + "\n")


def main():
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus = dbus.SessionBus()

    try:
        bus.add_match_string_non_blocking(
            "eavesdrop=true,"
            "interface='org.freedesktop.Notifications',"
            "member='Notify'"
        )
    except dbus.exceptions.DBusException as e:
        print(f"Could not add match string: {e}")
        return

    bus.add_message_filter(on_notification)

    print(f"Logging notifications to {LOG_FILE}")
    loop = GLib.MainLoop()
    try:
        loop.run()
    except KeyboardInterrupt:
        print("\nStopped.")


if __name__ == "__main__":
    main()
