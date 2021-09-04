/* Copyright 2015-2017 Sam Thomas
*
* This file is part of Hourglass.
*
* Hourglass is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Hourglass is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Hourglass. If not, see http://www.gnu.org/licenses/.
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
