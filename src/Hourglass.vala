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

using Granite.Services;

using Hourglass.Window;
using Hourglass.Services;

namespace Hourglass {

    /* Global - App wide variables */
    public DBusManager dbus_manager;
    public HourglassClient dbus_server;

    /* Settings */
    public SavedState saved;
    public SystemTimeFormat system_time_format;

    /* State */
    public MainWindow main_window;
	public bool window_open;

    public class HourglassApp : Gtk.Application {

        construct {
            application_id = "com.github.sgpthomas.client";
        }

        //constructor
        public HourglassApp () {
            /* Logger initilization */
            Logger.initialize (Constants.APP_NAME);
            Logger.DisplayLevel = LogLevel.DEBUG;

            /* Settings */
            saved = new SavedState ();
            system_time_format = new SystemTimeFormat ();

            // attempt to spawn daemon
            spawn_daemon ();

            /* Managers */
            dbus_manager = new DBusManager ();
            dbus_server = dbus_manager.client;
        }

        public override void activate () {
            if (main_window == null) {
                main_window = new MainWindow (this);
				window_open = true;
                Gtk.main ();
            } else {
                message ("There is an instance of hourglass already open.");
				main_window.deiconify ();
            }
        }

        private void spawn_daemon () {
            message ("starting daemon");
            string[] spawn_args = {"com.github.sgpthomas.hourglass-daemon"}; // command name

            //try to spawn daemon
            try {
                GLib.Process.spawn_async ("/", spawn_args, Environ.get () , GLib.SpawnFlags.SEARCH_PATH, null, null);
            } catch (GLib.SpawnError e) {
                error ("Spawning error message: %s".printf (e.message));
            }
        }
    }

    public static void main(string[] args) {
        Gtk.init (ref args);

        HourglassApp app = new HourglassApp ();
        app.run (args);
    }
}
