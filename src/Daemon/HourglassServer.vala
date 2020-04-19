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

extern void exit (int exit_code);

namespace HourglassDaemon {

    [DBus (name = "com.github.sgpthomas.hourglass")]
    public class Server : Object {

        public void print_message (string msg) throws Error{
            message (msg);
        }

        public void show_notification (string summary, string body = "", string track = "") throws Error {
            notification.show (summary, body, track);
        }

        public void add_alarm (string alarm) throws Error {
            message (alarm);
            manager.add_alarm (alarm);
        }

        public void remove_alarm (string alarm) throws Error {
            message (alarm);
            manager.remove_alarm (alarm);
        }

        public string[] get_alarm_list () throws Error {
            string[] list = {};
            foreach (string s in manager.alarm_list) {
                list += s;
            }
            return list;
        }

        public void toggle_alarm (string alarm) throws Error {
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
                      (c, name) => { message ("%s was successfully registered!", name); },
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
