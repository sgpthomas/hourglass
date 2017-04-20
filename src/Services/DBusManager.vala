/* Copyright 2015 Sam Thomas
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

namespace Hourglass.Services {

    [DBus (name = "net.launchpad.hourglass")]
    public interface HourglassClient : Object {
        public abstract void print_message (string msg) throws IOError;
        public abstract void show_notification (string summary, string body = "", string track = "") throws IOError;
        public abstract void add_alarm (string alarm) throws IOError;
        public abstract void remove_alarm (string alarm) throws IOError;
        public abstract string[] get_alarm_list () throws IOError;
        public abstract void toggle_alarm (string alarm) throws IOError;
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
                client = Bus.get_proxy_sync (BusType.SESSION, "net.launchpad.hourglass", "/net/launchpad/hourglass");

                client.print_message ("Client Starting");

            } catch (IOError e) {
                error ("%s", e.message);
            }
        }
    }
}
