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

using Hourglass.Window;
using Hourglass.Services;

namespace Hourglass {

    /* Global - App wide variables */
    public DBusManager dbus_manager;
    public HourglassClient dbus_server;

    /* Settings */
    public static GLib.Settings saved;
    public static GLib.Settings system_time_format;

    /* State */
    public MainWindow main_window;
    public bool window_open;

    public class HourglassApp : Gtk.Application {

        construct {
            application_id = "com.github.sgpthomas.client";
        }

        static construct {
            /* Settings */
            saved = new GLib.Settings ("com.github.sgpthomas.hourglass.saved");
            system_time_format = new GLib.Settings ("org.gnome.desktop.interface");
        }

        //constructor
        public HourglassApp () {
            /* Managers */
            dbus_manager = new DBusManager ();
            dbus_server = dbus_manager.client;
        }

        public override void activate () {
            if (main_window != null) {
                debug ("There is an instance of hourglass already open.");
                main_window.deiconify ();
                return;
            }

            main_window = new MainWindow ();

            if (Hourglass.saved.get_boolean ("is-maximized")) {
                main_window.maximize ();
            } else {
                int window_width, window_height;
                Hourglass.saved.get ("window-size", "(ii)", out window_width, out window_height);
                main_window.resize (window_width, window_height);
            }

            int widnow_x, window_y;
            Hourglass.saved.get ("window-position", "(ii)", out widnow_x, out window_y);
            if (widnow_x != -1 | window_y != -1) {
                main_window.move (widnow_x, window_y);
            } else {
                main_window.window_position = Gtk.WindowPosition.CENTER;
            }

            window_open = true;
            Gtk.main ();
        }

        public static void spawn_daemon () {
            debug ("starting daemon");
            string[] spawn_args = {"com.github.sgpthomas.hourglass-daemon"}; // command name

            //try to spawn daemon
            try {
                GLib.Process.spawn_async ("/", spawn_args, Environ.get () , GLib.SpawnFlags.SEARCH_PATH, null, null);
            } catch (GLib.SpawnError e) {
                error ("Spawning error message: %s".printf (e.message));
            }
        }
    }

    public static void main (string[] args) {
        // attempt to spawn daemon
        HourglassApp.spawn_daemon ();

        Gtk.init (ref args);
        Hdy.init ();

        HourglassApp app = new HourglassApp ();
        app.run (args);
    }
}
