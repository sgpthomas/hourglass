/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2022 Sam Thomas
 */

namespace Hourglass.Services {

    [DBus (name = "com.github.sgpthomas.hourglass")]
    public interface HourglassClient : Object {
        public abstract void show_notification (string summary, string body, string id) throws GLib.DBusError, GLib.IOError;
        public abstract void add_alarm (string alarm) throws GLib.DBusError, GLib.IOError;
        public abstract void remove_alarm (string alarm) throws GLib.DBusError, GLib.IOError;
        public abstract string[] get_alarm_list () throws GLib.DBusError, GLib.IOError;
        public abstract void toggle_alarm (string alarm) throws GLib.DBusError, GLib.IOError;
        public signal void should_refresh_client ();
    }

    public class DBusManager {

        //client interface
        public HourglassClient client;

        public DBusManager () {
            sync_server ();
        }

        private void sync_server () {
            try {
                //sync client to server
                client = Bus.get_proxy_sync (BusType.SESSION, "com.github.sgpthomas.hourglass", "/com/github/sgpthomas/hourglass");
            } catch (GLib.IOError e) {
                error (e.message);
            }
        }
    }
}
