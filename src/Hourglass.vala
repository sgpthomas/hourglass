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
    public bool running = false;
    //public bool window = false;
    public MainWindow main_window;

    public class HourglassApp : Granite.Application {

        construct {
            program_name = Constants.APP_NAME;
            exec_name = Constants.EXEC_NAME;
            build_version = Constants.VERSION;

            app_years = "2015-2017";
            app_icon = Constants.ICON_NAME;
            app_launcher = "com.github.sgpthomas.hourglass.desktop";
            application_id = "com.github.sgpthomas.client";

            main_url = "https://github.com/sgpthomas/hourglass";
            bug_url = "https://github.com/sgpthomas/hourglass/issues";
            help_url = "https://github.com/sgpthomas/hourglass/issues";
            translate_url = "http://translations.launchpad.net/hourglass";

            about_authors = {"Sam Thomas <sgpthomas@gmail.com>"};
            about_license_type = Gtk.License.GPL_3_0;
            about_artists = {"Sam Thomas <sgpthomas@gmail.com>"};
            about_translators = "Launchpad Translators";
        }

        /* Object-wide variables */
        //public MainWindow main_window;

        //constructor
        public HourglassApp () {
            /* Logger initilization */
            Logger.initialize (Constants.APP_NAME);
            Logger.DisplayLevel = LogLevel.DEBUG;

            /* Settings */
            saved = new SavedState ();
            system_time_format = new SystemTimeFormat ();

            //attempt to spawn daemon
            spawn_daemon ();

            /* Managers */
            dbus_manager = new DBusManager ();
            dbus_server = dbus_manager.client;

            /* Translation support */
            Intl.setlocale (LocaleCategory.ALL, "");
            string langpack_dir = Path.build_filename (Constants.DATADIR, "locale");
            Intl.bindtextdomain (Constants.GETTEXT_PACKAGE, langpack_dir);
            Intl.bind_textdomain_codeset (Constants.GETTEXT_PACKAGE, "UTF-8");
            Intl.textdomain (Constants.GETTEXT_PACKAGE);

            //init ();
        }

        public override void activate () {
            if (main_window == null) {
                main_window = new MainWindow (this);
                //connect_signals ();
                Gtk.main ();
            } else {
                message ("There is an instance of hourglass already open.");
                main_window = new MainWindow (this);
            }
        }

        private void spawn_daemon () {
            message ("starting daemon");
            string[] spawn_args = {"hourglass-daemon"}; //command name

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
