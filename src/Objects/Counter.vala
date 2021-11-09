/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2021 Sam Thomas
 */

public class Hourglass.Objects.Counter : GLib.Object {
    public enum CountDirection {
        UP,
        DOWN
    }

    public signal void ticked ();
    public signal void started ();
    public signal void stopped ();
    public signal void ended ();

    private uint timeout_id;
    private uint inhibit_token = 0;

    public CountDirection direction { get; construct; }

    public bool is_active { get; private set; }

    // in milliseconds
    public int64 current_time { get; private set; default = 0; }
    public int64 limit {
        get {
            return _limit;
        }
        set {
            _limit = value;
            current_time = value;
        }
    }
    private int64 _limit;

    private int64 last_time = 0; // in milliseconds
    private DateTime start_time;

    public bool should_notify = false;
    private string notify_summary;
    private string notify_body;
    private string notify_id;

    public Counter (CountDirection direction) {
        Object (direction: direction);
    }

    construct {
        notify["is-active"].connect (() => {
            if (is_active) {
                unowned Gtk.Application app = (Gtk.Application) GLib.Application.get_default ();
                if (inhibit_token != 0) {
                    app.uninhibit (inhibit_token);
                }

                inhibit_token = app.inhibit (
                    app.get_active_window (),
                    Gtk.ApplicationInhibitFlags.IDLE | Gtk.ApplicationInhibitFlags.SUSPEND,
                    _("Timer is active")
                );
            } else {
                if (inhibit_token != 0) {
                    ((Gtk.Application) GLib.Application.get_default ()).uninhibit (inhibit_token);
                    inhibit_token = 0;
                }
            }
        });
    }

    public void reset () {
        current_time = 0;
        last_time = 0;
    }

    public void start () {
        start_time = new DateTime.now_local ();

        if (timeout_id == 0) {
            timeout_id = Timeout.add (10, tick);
        }

        is_active = true;
        started ();
    }

    public void stop () {
        last_time = current_time;
        if (timeout_id != 0) {
            Source.remove (timeout_id);
            timeout_id = 0;
        }

        is_active = false;
        stopped ();
    }

    private bool tick () {
        var diff = (int64) (new DateTime.now_local ()).difference (start_time);

        if (direction == CountDirection.UP) {
            current_time = diff + last_time;
        } else {
            if (current_time >= 0) {
                current_time = limit - diff;
            } else {
                if (should_notify) {
                    try {
                        Hourglass.dbus_server.show_notification (notify_summary, notify_body, notify_id);
                    } catch (Error e) {
                        error (e.message);
                    }
                }

                current_time = limit;
                stop ();
                ended ();
            }
        }

        ticked ();

        return true;
    }

    public void set_notification (string summary, string body, string id) {
        notify_summary = summary;
        notify_body = body;
        notify_id = id;
    }
}
