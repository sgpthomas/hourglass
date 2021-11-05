/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2021 Sam Thomas
 */

extern void exit (int exit_code);

namespace HourglassDaemon {

    [DBus (name = "com.github.sgpthomas.hourglass")]
    public class Server : Object {

        public void show_notification (string summary, string body, string id) throws GLib.DBusError, GLib.IOError {
            notification.show (summary, body, id);
        }

        public void add_alarm (string alarm) throws GLib.DBusError, GLib.IOError {
            debug (alarm);
            manager.add_alarm (alarm);
        }

        public void remove_alarm (string alarm) throws GLib.DBusError, GLib.IOError {
            debug (alarm);
            manager.remove_alarm (alarm);
        }

        public string[] get_alarm_list () throws GLib.DBusError, GLib.IOError {
            string[] list = {};
            foreach (string s in manager.alarm_list) {
                list += s;
            }
            return list;
        }

        public void toggle_alarm (string alarm) throws GLib.DBusError, GLib.IOError {
            manager.toggle_alarm (alarm);
        }

        public signal void should_refresh_client ();
    }

    [DBus (name = "com.github.sgpthomas.hourglass")]
    public errordomain HourglassError {
        SOME_ERROR
    }

    public class HourglassServer {

        public Server server;

        public HourglassServer () {

            server = new Server ();

            // try to register server name in session bus
            Bus.own_name (BusType.SESSION,
                      "com.github.sgpthomas.hourglass",
                      BusNameOwnerFlags.NONE,
                      (conn) => { on_bus_aquired (conn); },
                      (c, name) => { debug ("%s was successfully registered!", name); },
                      () => { critical ("Could not aquire service name"); exit (-1); });
        }

        private void on_bus_aquired (DBusConnection connection) {
            try {
                // start service and register it as dbus object
                connection.register_object ("/com/github/sgpthomas/hourglass", server);
            } catch (IOError e) {
                critical ("Could not register service: %s", e.message);
            }
        }
    }
}
